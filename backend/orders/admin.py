from django.contrib import admin
from .models import Order, OrderItem


class OrderItemInline(admin.TabularInline):
    model = OrderItem
    extra = 0
    raw_id_fields = ['product', 'farmer']


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ['id', 'buyer', 'total_amount', 'status', 'payment_status', 'payment_method', 'created_at']
    list_filter = ['status', 'payment_status', 'payment_method']
    search_fields = ['buyer__name', 'shipping_address']
    raw_id_fields = ['buyer']
    inlines = [OrderItemInline]
