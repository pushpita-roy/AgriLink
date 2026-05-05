from rest_framework import serializers
from .models import Product


class ProductSerializer(serializers.ModelSerializer):
    farmer_name = serializers.CharField(source='farmer.name', read_only=True)
    farmer_id = serializers.IntegerField(source='farmer.id', read_only=True)
    image_path = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = [
            'id', 'farmer_id', 'farmer_name', 'name', 'category',
            'description', 'unit_type', 'price_per_unit', 'stock_qty',
            'location', 'harvest_date', 'image', 'image_url', 'image_path',
            'rating', 'created_at',
        ]
        read_only_fields = ['id', 'created_at', 'farmer_id', 'farmer_name']

    def get_image_path(self, obj):
        request = self.context.get('request')
        if obj.image and hasattr(obj.image, 'url'):
            if request:
                return request.build_absolute_uri(obj.image.url)
            return obj.image.url
        return obj.image_url or ''


class ProductCreateUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = [
            'name', 'category', 'description', 'unit_type',
            'price_per_unit', 'stock_qty', 'location', 'harvest_date',
            'image', 'image_url', 'rating',
        ]
