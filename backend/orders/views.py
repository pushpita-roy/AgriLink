from rest_framework import status, generics
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Q

from products.models import Product
from .models import Order, OrderItem
from .serializers import (
    OrderSerializer, OrderCreateSerializer, OrderStatusUpdateSerializer,
)


class OrderListView(generics.ListAPIView):
    """
    List orders for the current user.
    Buyers see their own orders.
    Farmers see orders containing their products.
    Admins see all orders.
    """
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        qs = Order.objects.select_related('buyer').prefetch_related(
            'items__product', 'items__farmer'
        )

        if user.role == 'admin':
            pass  # admin sees all
        elif user.role == 'farmer':
            qs = qs.filter(items__farmer=user).distinct()
        else:
            qs = qs.filter(buyer=user)

        # Filters
        order_status = self.request.query_params.get('status')
        if order_status and order_status != 'all':
            qs = qs.filter(status=order_status)

        payment_status = self.request.query_params.get('payment_status')
        if payment_status and payment_status != 'all':
            qs = qs.filter(payment_status=payment_status)

        search = self.request.query_params.get('search')
        if search:
            qs = qs.filter(
                Q(id__icontains=search) |
                Q(shipping_address__icontains=search) |
                Q(items__product_name__icontains=search)
            ).distinct()

        date_from = self.request.query_params.get('date_from')
        if date_from:
            qs = qs.filter(created_at__date__gte=date_from)
        date_to = self.request.query_params.get('date_to')
        if date_to:
            qs = qs.filter(created_at__date__lte=date_to)

        # Sorting
        sort = self.request.query_params.get('sort')
        if sort == 'oldest':
            qs = qs.order_by('created_at')
        elif sort == 'amount_desc':
            qs = qs.order_by('-total_amount')
        elif sort == 'amount_asc':
            qs = qs.order_by('total_amount')

        return qs


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def place_order_view(request):
    """Place a new order from cart items."""
    serializer = OrderCreateSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    data = serializer.validated_data

    # Build order items and calculate total
    order_items_data = []
    total_amount = 0

    for item_data in data['items']:
        try:
            product = Product.objects.get(pk=item_data['product_id'])
        except Product.DoesNotExist:
            return Response(
                {'detail': f"Product {item_data['product_id']} not found."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if product.stock_qty < item_data['quantity']:
            return Response(
                {'detail': f"Insufficient stock for {product.name}."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        line_total = product.price_per_unit * item_data['quantity']
        total_amount += line_total
        order_items_data.append({
            'product': product,
            'farmer': product.farmer,
            'product_name': product.name,
            'unit_price': product.price_per_unit,
            'quantity': item_data['quantity'],
        })

    # Create order
    order = Order.objects.create(
        buyer=request.user,
        total_amount=total_amount,
        payment_method=data.get('payment_method', 'COD'),
        shipping_address=data['shipping_address'],
    )

    # Create order items and reduce stock
    for item_data in order_items_data:
        product = item_data.pop('product')
        OrderItem.objects.create(order=order, product=product, **item_data)
        product.stock_qty -= item_data['quantity']
        product.save(update_fields=['stock_qty'])

    # Clear the user's cart
    request.user.cart_items.all().delete()

    order = Order.objects.select_related('buyer').prefetch_related(
        'items__product', 'items__farmer'
    ).get(pk=order.pk)

    return Response(
        OrderSerializer(order).data,
        status=status.HTTP_201_CREATED,
    )


class OrderDetailView(generics.RetrieveAPIView):
    """Get order detail."""
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Order.objects.select_related('buyer').prefetch_related(
            'items__product', 'items__farmer'
        )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def order_stats_view(request):
    """
    Get order statistics for the dashboard.
    Admins see platform totals.
    Others see personal totals.
    """
    user = request.user
    
    if user.role == 'admin':
        # Admin: Fetch EVERY order in the database
        total_orders = Order.objects.count()
        pending_orders = Order.objects.filter(status='Pending').count()
    elif user.role == 'farmer':
        # Farmer: Only count orders containing their products
        # Using .distinct() to avoid double counting if multiple products are in one order
        farmer_orders = Order.objects.filter(items__farmer=user).distinct()
        total_orders = farmer_orders.count()
        pending_orders = farmer_orders.filter(status='Pending').count()
    else:
        # Buyer: Only count orders they placed
        buyer_orders = Order.objects.filter(buyer=user)
        total_orders = buyer_orders.count()
        pending_orders = buyer_orders.filter(status='Pending').count()

    return Response({
        'total_orders': total_orders,
        'pending_orders': pending_orders,
    }, status=status.HTTP_200_OK)