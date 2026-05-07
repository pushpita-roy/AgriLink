from rest_framework import serializers
from .models import Order, OrderItem


class OrderItemSerializer(serializers.ModelSerializer):
    line_total = serializers.SerializerMethodField()
    product_id = serializers.IntegerField(source='product.id', read_only=True)
    farmer_id = serializers.IntegerField(source='farmer.id', read_only=True)

    class Meta:
        model = OrderItem
        fields = [
            'id', 'product_id', 'product_name', 'farmer_id',
            'unit_price', 'quantity', 'line_total',
        ]
        read_only_fields = ['id']

    def get_line_total(self, obj):
        return float(obj.unit_price * obj.quantity)


class OrderItemCreateSerializer(serializers.Serializer):
    product_id = serializers.IntegerField()
    quantity = serializers.IntegerField(min_value=1)


class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    buyer_id = serializers.IntegerField(source='buyer.id', read_only=True)
    status_text = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = Order
        fields = [
            'id', 'buyer_id', 'total_amount', 'payment_method',
            'payment_status', 'status', 'status_text',
            'shipping_address', 'items', 'created_at',
        ]
        read_only_fields = ['id', 'created_at', 'buyer_id']


class OrderCreateSerializer(serializers.Serializer):
    payment_method = serializers.ChoiceField(choices=['COD', 'Bkash', 'Nagad'], default='COD')
    shipping_address = serializers.CharField(required=False, allow_blank=True)
    items = OrderItemCreateSerializer(many=True)

    def validate_items(self, value):
        if not value:
            raise serializers.ValidationError('Order must contain at least one item.')
        return value


class OrderStatusUpdateSerializer(serializers.Serializer):
    status = serializers.ChoiceField(
        choices=['pending', 'confirmed', 'cancelled', 'shipped', 'delivered']
    )
    payment_status = serializers.ChoiceField(
        choices=['pending', 'paid', 'failed'],
        required=False,
    )
