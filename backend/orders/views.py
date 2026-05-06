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


# Replace the line that crashes with this:
try:
    # This is a safer way to clear the cart if you use a Cart model
    from cart.models import CartItem # Import your cart model
    CartItem.objects.filter(user=request.user).delete()
except:
    pass # If cart clearing fails, don't crash the whole order!

    return Response(OrderSerializer(order).data, status=201)


# --- ২. নতুন অর্ডার প্লে করার লজিক (The Fixed Logic) ---
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def place_order_view(request):
    serializer = OrderCreateSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    data = serializer.validated_data

    order_items_data = []
    total_amount = 0

    # ধাপ ১: স্টক চেক
    for item_data in data['items']:
        try:
            product = Product.objects.select_for_update().get(pk=item_data['product_id'])
        except Product.DoesNotExist:
            return Response({'detail': f"Product with ID {item_data['product_id']} not found."}, status=400)

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

    # ধাপ ২: ডাটাবেজ সেভ
    try:
        with transaction.atomic():
            # অর্ডার তৈরি
            order = Order.objects.create(
                buyer=request.user,
                total_amount=total_amount,
                payment_method=data.get('payment_method', 'COD'),
                shipping_address=data['shipping_address'],
            )

            # আইটেম তৈরি এবং স্টক আপডেট
            for item_info in order_items_data:
                product = item_info.pop('product')
                OrderItem.objects.create(order=order, product=product, **item_info)

                product.stock_qty -= item_info['quantity']
                product.save(update_fields=['stock_qty'])

            # ধাপ ৩: কার্ট খালি করা (Safe Method)
            try:
                # If you have a Cart model in an app named 'cart'
                from cart.models import CartItem
                CartItem.objects.filter(user=request.user).delete()
            except Exception:
                # If the above fails, try the related_name method
                try:
                    request.user.cart_items.all().delete()
                except Exception:
                    pass # Keep going so the user sees the order success

            return Response(OrderSerializer(order).data, status=201)

    except Exception as e:
        # This will tell Flutter the EXACT database error if one occurs
        return Response({'detail': str(e)}, status=500)

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