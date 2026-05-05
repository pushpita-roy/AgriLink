from django.contrib import admin
from .models import Product


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ['name', 'farmer', 'category', 'price_per_unit', 'stock_qty', 'rating']
    list_filter = ['category', 'unit_type']
    search_fields = ['name', 'category', 'farmer__name']
    raw_id_fields = ['farmer']
