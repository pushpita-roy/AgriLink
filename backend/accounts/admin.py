from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ['username', 'name', 'email', 'role', 'is_verified', 'division' , 'district']
    list_filter = ['role', 'is_verified', 'district' , 'division']
    search_fields = ['name', 'email', 'district' , 'division']
    fieldsets = BaseUserAdmin.fieldsets + (
        ('AgriLink Fields', {
            'fields': ('name', 'role', 'phone', 'address', 'district', 'division' , 'farm_name', 'is_verified'),
        }),
    )