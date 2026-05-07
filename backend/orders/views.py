from decimal import Decimal  # Added critical import at the top
from rest_framework import status, generics
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Q, Sum
from django.db import transaction

from products.models import Product
from .models import Order, OrderItem
from .serializers import (
    OrderSerializer, OrderCreateSerializer, OrderStatusUpdateSerializer,
)

# --- 1. Order List View ---
class OrderListView(generics.ListAPIView):
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        qs = Order.objects.select_related('buyer').prefetch_related(
            'items__product', 'items__farmer'
        )

        role = getattr(user, 'role', '').lower()
        if role == 'farmer':
            qs = qs.filter(items__farmer=user).distinct()
        elif role != 'admin':
            qs = qs.filter(buyer=user)

        order_status = self.request.query_params.get('status')
        if order_status and order_status != 'all':
            qs = qs.filter(status=order_status)

        search = self.request.query_params.get('search')
        if search:
            qs = qs.filter(
                Q(id__icontains=search) |
                Q(shipping_address__icontains=search)
            ).distinct()

        return qs.order_by('-created_at')


# --- 2. Place Order View ---
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def place_order_view(request):
    serializer = OrderCreateSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    data = serializer.validated_data

    order_items_data = []
    total_amount = Decimal('0.00') 

    # 1. Logic & Stock Check
    for item_data in data['items']:
        try:
            p_id = int(item_data['product_id'])
            # select_for_update prevents race conditions
            product = Product.objects.select_for_update().get(pk=p_id)
            
            qty = int(item_data['quantity'])
            if product.stock_qty < qty:
                return Response({'detail': f"No stock for {product.name}"}, status=400)

            # Use product price directly from DB to ensure accuracy
            price = Decimal(str(product.price_per_unit))
            total_amount += (price * qty)
            
            order_items_data.append({
                'product': product,
                'unit_price': price,
                'quantity': qty,
                'product_name': product.name,
                'farmer': product.farmer
            })
        except Exception as e:
            return Response({'detail': f"Product Error: {str(e)}"}, status=400)

    # 2. Database Save
    try:
        with transaction.atomic():
            order = Order.objects.create(
                buyer=request.user,
                total_amount=total_amount,
                payment_method=data.get('payment_method', 'COD'),
                # Safe check: uses blank string if address is missing in validated_data
                shipping_address=data.get('shipping_address', ''), 
            )

            for item in order_items_data:
                p = item.pop('product')
                OrderItem.objects.create(order=order, product=p, **item)
                
                # Update Stock
                p.stock_qty -= item['quantity']
                p.save(update_fields=['stock_qty'])

            # 3. Silent Cart Clear
            try:
                request.user.cart_items.all().delete()
            except:
                pass

            return Response(OrderSerializer(order).data, status=201)
            
    except Exception as e:
        # returns actual error message for debugging
        return Response({'detail': f"Database Error: {str(e)}"}, status=500)


# --- 3. Update Order Status ---
@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def update_order_status_view(request, pk):
    try:
        order = Order.objects.get(pk=pk)
    except Order.DoesNotExist:
        return Response({'detail': 'Order not found.'}, status=404)

    if request.user.role.lower() not in ('admin', 'farmer'):
        return Response({'detail': 'Permission denied.'}, status=403)

    serializer = OrderStatusUpdateSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    new_status = serializer.validated_data['status']

    if new_status.upper() == 'CANCELLED' and order.status.upper() != 'CANCELLED':
        for item in order.items.all():
            if item.product:
                item.product.stock_qty += item.quantity
                item.product.save(update_fields=['stock_qty'])

    order.status = new_status
    if 'payment_status' in serializer.validated_data:
        order.payment_status = serializer.validated_data['payment_status']

    order.save()
    return Response(OrderSerializer(order).data)


# --- 4. Dashboard Stats ---
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def order_stats_view(request):
    user = request.user
    role = getattr(user, 'role', '').lower()

    if role == 'admin':
        orders_qs = Order.objects.all()
    elif role == 'farmer':
        orders_qs = Order.objects.filter(items__farmer=user).distinct()
    else:
        orders_qs = Order.objects.filter(buyer=user)

    revenue = orders_qs.filter(
        payment_status__iexact='paid',
        status__iexact='delivered'
    ).aggregate(Sum('total_amount'))['total_amount__sum'] or 0

    return Response({
        'total_orders': orders_qs.count(),
        'pending_orders': orders_qs.filter(status__iexact='pending').count(),
        'total_revenue': revenue,
    })