from rest_framework import status, generics
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Q, Sum
from django.db import transaction  # ডাটাবেজ নিরাপত্তার জন্য জরুরি

from products.models import Product
from .models import Order, OrderItem
from .serializers import (
    OrderSerializer, OrderCreateSerializer, OrderStatusUpdateSerializer,
)

# --- ১. অর্ডার লিস্ট ভিউ (Admin, Farmer, Buyer ফিল্টারিং) ---
class OrderListView(generics.ListAPIView):
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        qs = Order.objects.select_related('buyer').prefetch_related(
            'items__product', 'items__farmer'
        )

        # ইউজার রোল অনুযায়ী ফিল্টারিং
        role = getattr(user, 'role', '').lower()
        if role == 'admin':
            pass
        elif role == 'farmer':
            qs = qs.filter(items__farmer=user).distinct()
        else:
            qs = qs.filter(buyer=user)

        # স্ট্যাটাস এবং সার্চ ফিল্টার
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


# --- ২. নতুন অর্ডার প্লে করার লজিক (The Fixed Logic) ---
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def place_order_view(request):
    serializer = OrderCreateSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    data = serializer.validated_data

    order_items_data = []
    total_amount = 0

    # ধাপ ১: আগে সব প্রোডাক্টের স্টক চেক করে নিন
    for item_data in data['items']:
        try:
            # select_for_update() দিলে একই সাথে দুইজন ইউজার একই স্টক কিনতে পারবে না
            product = Product.objects.select_for_update().get(pk=item_data['product_id'])
        except Product.DoesNotExist:
            return Response({'detail': f"Product not found."}, status=400)

        if product.stock_qty < item_data['quantity']:
            return Response(
                {'detail': f"Insufficient stock for {product.name}. Available: {product.stock_qty}"},
                status=400
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

    # ধাপ ২: ট্রানজেকশন শুরু (সব ঠিক থাকলেই ডাটাবেজে সেভ হবে)
    try:
        with transaction.atomic():
            order = Order.objects.create(
                buyer=request.user,
                total_amount=total_amount,
                payment_method=data.get('payment_method', 'COD'),
                shipping_address=data['shipping_address'],
            )

            for item_info in order_items_data:
                product = item_info.pop('product')
                OrderItem.objects.create(order=order, product=product, **item_info)

                # স্টক কমিয়ে আপডেট করা
                product.stock_qty -= item_info['quantity']
                product.save(update_fields=['stock_qty'])

            # কার্ট খালি করা
            request.user.cart_items.all().delete()

    except Exception:
        return Response({'detail': "Server error during order processing."}, status=500)

    return Response(OrderSerializer(order).data, status=201)


# --- ৩. অর্ডার স্ট্যাটাস আপডেট (Cancel হলে স্টক ফেরত) ---
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

    # স্টক ম্যানেজমেন্ট যদি অর্ডার ক্যান্সেল হয়
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


# --- ৪. ড্যাশবোর্ড স্ট্যাটাস (Admin Revenue Logic) ---
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def order_stats_view(request):
    user = request.user
    role = getattr(user, 'role', '').lower()

    # বেস কোয়েরি
    if role == 'admin':
        orders_qs = Order.objects.all()
    elif role == 'farmer':
        orders_qs = Order.objects.filter(items__farmer=user).distinct()
    else:
        orders_qs = Order.objects.filter(buyer=user)

    # রেভিনিউ লজিক: শুধুমাত্র Paid এবং Delivered হলে যোগ হবে
    revenue = orders_qs.filter(
        payment_status__iexact='paid',
        status__iexact='delivered'
    ).aggregate(Sum('total_amount'))['total_amount__sum'] or 0

    return Response({
        'total_orders': orders_qs.count(),
        'pending_orders': orders_qs.filter(status__iexact='pending').count(),
        'total_revenue': revenue,
    })