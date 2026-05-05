from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import User
from django.core.validators import validate_email as django_validate_email
from django.core.exceptions import ValidationError as DjangoValidationError
from cart.models import CartItem
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'id', 'name', 'email', 'role', 'phone', 'address',
            'district',  'division' , 'farm_name', 'is_verified', 'date_joined',
        ]
        read_only_fields = ['id', 'date_joined']

class RegisterSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=200)
    email = serializers.EmailField()
    password = serializers.CharField(min_length=6, write_only=True)
    role = serializers.ChoiceField(choices=['buyer', 'farmer', 'admin'])
    # 1. ADD THIS LINE HERE:
    division = serializers.CharField(max_length=100, required=False, allow_blank=True)

    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("An account with this email already exists")

        allowed_domains = ('@gmail.com', '@yahoo.com', '@hotmail.com')
        if not value.lower().endswith(allowed_domains):
            # This is the message that will be sent to the frontend
            raise serializers.ValidationError("Only @gmail.com, @yahoo.com, or @hotmail.com are allowed")

        return value

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['email'],
            email=validated_data['email'],
            password=validated_data['password'],
            name=validated_data['name'],
            role=validated_data['role'],
            # 2. AND ADD THIS LINE HERE:
            division=validated_data.get('division', ''),
        )
        return user

# ... (LoginSerializer code is below this)


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField()
    role = serializers.ChoiceField(choices=['buyer', 'farmer', 'admin'])

    def validate(self, data):
        from django.contrib.auth import authenticate

        # 1. First, check if the email and role match a user in the database
        try:
            user = User.objects.get(email=data['email'], role=data['role'])
        except User.DoesNotExist:
            # If we can't find the email/role, we know the account is the problem
            raise serializers.ValidationError('No account found with this email and role.')

        # 2. If the user exists, check if the password is correct
        # Note: we use user.username because Django's authenticate often uses the username field
        authenticated_user = authenticate(username=user.username, password=data['password'])

        if authenticated_user is None:
            # If the user exists but authenticate fails, the password is wrong
            raise serializers.ValidationError('Incorrect password. Please try again.')

        # 3. Success! Attach the user to the data
        data['user'] = authenticated_user
        return data

class ProfileUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['name', 'phone', 'address', 'district', 'farm_name', 'division']

class CartItemSerializer(serializers.ModelSerializer):
    # Pulling data from the related Product model
    product_name = serializers.ReadOnlyField(source='product.name')
    location = serializers.ReadOnlyField(source='product.location')
    price_per_unit = serializers.ReadOnlyField(source='product.price_per_unit')
    unit_type = serializers.ReadOnlyField(source='product.unit_type')

    # Calculated/Method fields
    image_path = serializers.SerializerMethodField()
    line_total = serializers.ReadOnlyField() # This uses the @property from your CartItem model

    class Meta:
        model = CartItem
        fields = [
            'id',
            'product_id',
            'product_name',
            'location',
            'price_per_unit',
            'unit_type',
            'quantity',
            'image_path',
            'line_total'
        ]

    def get_image_path(self, obj):
        request = self.context.get('request')
        if obj.product and obj.product.image:
            if request:
                return request.build_absolute_uri(obj.product.image.url)
            return obj.product.image.url
        return None