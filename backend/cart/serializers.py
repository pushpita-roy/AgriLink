from rest_framework import serializers
from .models import CartItem
from rest_framework import serializers
from .models import CartItem

class CartItemSerializer(serializers.ModelSerializer):
    # Data pulled from the related Product model
    location = serializers.CharField(source='product.location', read_only=True)
    product_name = serializers.CharField(source='product.name', read_only=True)
    price_per_unit = serializers.DecimalField(source='product.price_per_unit', max_digits=10, decimal_places=2, read_only=True)
    unit_type = serializers.CharField(source='product.unit_type', read_only=True)

    stock_qty = serializers.DecimalField(source='product.stock_qty', max_digits=10, decimal_places=2, read_only=True)    

    image_path = serializers.SerializerMethodField()
    line_total = serializers.SerializerMethodField()

    class Meta:
        model = CartItem
        fields = [
            'id',
            'product_id',
            'product_name',
            'price_per_unit',
            'unit_type',
            'location',
            'quantity',
            'image_path',
            'line_total',
            'stock_qty'
        ]

    def get_image_path(self, obj):
        product = obj.product
        request = self.context.get('request')
        if product.image and hasattr(product.image, 'url'):
            if request:
                return request.build_absolute_uri(product.image.url)
            return product.image.url
        return ""

    def get_line_total(self, obj):
        return float(obj.product.price_per_unit * obj.quantity)


class CartItemCreateSerializer(serializers.Serializer):
    product_id = serializers.IntegerField()
    quantity = serializers.IntegerField(min_value=1, default=1)


class CartItemUpdateSerializer(serializers.Serializer):
    quantity = serializers.IntegerField(min_value=1)
