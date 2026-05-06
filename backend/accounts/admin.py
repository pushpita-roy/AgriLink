from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User
from rest_framework.authtoken.models import TokenProxy as Token # Import the Token model

# This class allows the Token to appear inside the User page
class TokenInline(admin.TabularInline):
    model = Token
    extra = 0
    can_delete = False
    readonly_fields = ('key', 'created')

@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ['username', 'name', 'email', 'role', 'is_verified', 'division', 'district']
    list_filter = ['role', 'is_verified', 'district', 'division']
    search_fields = ['name', 'email', 'district', 'division']
    
    # Add the TokenInline here
    inlines = [TokenInline]

    fieldsets = BaseUserAdmin.fieldsets + (
        ('AgriLink Fields', {
            'fields': ('name', 'role', 'phone', 'address', 'district', 'division', 'farm_name', 'is_verified'),
        }),
    )

    add_fieldsets = BaseUserAdmin.add_fieldsets + (
        ('AgriLink Fields', {
            'fields': ('name', 'role', 'phone', 'address', 'district', 'division', 'farm_name', 'is_verified'),
        }),
    )