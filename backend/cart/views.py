from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from products.models import Product
from .models import CartItem
from .serializers import (
    CartItemSerializer, CartItemCreateSerializer, CartItemUpdateSerializer,
)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def cart_list_view(request):
    """Get the current user's cart items."""
    items = CartItem.objects.select_related('product', 'product__farmer').filter(
        user=request.user
    )
    serializer = CartItemSerializer(items, many=True, context={'request': request})
    total_amount = sum(item.line_total for item in items)
    return Response({
        'items': serializer.data,
        'item_count': items.count(),
        'total_amount': float(total_amount),
    })

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def cart_add_view(request):
    serializer = CartItemCreateSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    try:
        product = Product.objects.get(pk=serializer.validated_data['product_id'])
    except Product.DoesNotExist:
        return Response({'detail': 'Product not found.'}, status=status.HTTP_404_NOT_FOUND)

    requested_add_qty = serializer.validated_data.get('quantity', 1)

    cart_item, created = CartItem.objects.get_or_create(
        user=request.user,
        product=product,
        defaults={'quantity': 0}, # Start at 0 to check stock properly
    )

    # CHECK STOCK HERE (Changed .stock to .stock_qty)
    new_total_qty = cart_item.quantity + requested_add_qty
    if new_total_qty > product.stock_qty:
        return Response(
            {'detail': f'Only {product.stock_qty} units available in stock.'},
            status=status.HTTP_400_BAD_REQUEST
        )

    cart_item.quantity = new_total_qty
    cart_item.save()

    return Response(
        CartItemSerializer(cart_item, context={'request': request}).data,
        status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
    )

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def cart_update_view(request, pk):
    try:
        cart_item = CartItem.objects.select_related('product').get(
            pk=pk, user=request.user,
        )
    except CartItem.DoesNotExist:
        return Response({'detail': 'Cart item not found.'}, status=status.HTTP_404_NOT_FOUND)

    serializer = CartItemUpdateSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    new_quantity = serializer.validated_data['quantity']

    # CHECK STOCK HERE (Changed .stock to .stock_qty)
    if new_quantity > cart_item.product.stock_qty:
        return Response(
            {'detail': f'Cannot exceed available stock ({cart_item.product.stock_qty}).'},
            status=status.HTTP_400_BAD_REQUEST
        )

    cart_item.quantity = new_quantity
    cart_item.save()

    return Response(CartItemSerializer(cart_item, context={'request': request}).data)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def cart_remove_view(request, pk):
    """Remove a specific item from the cart."""
    deleted, _ = CartItem.objects.filter(pk=pk, user=request.user).delete()
    if not deleted:
        return Response(
            {'detail': 'Cart item not found.'},
            status=status.HTTP_404_NOT_FOUND,
        )
    return Response(status=status.HTTP_204_NO_CONTENT)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def cart_clear_view(request):
    """Clear all items from the user's cart."""
    CartItem.objects.filter(user=request.user).delete()
    return Response({'detail': 'Cart cleared.'}, status=status.HTTP_200_OK)