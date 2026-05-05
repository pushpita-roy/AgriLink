import re
from rest_framework import status, generics
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from django.db.models import Sum

from .models import User
from .serializers import (
    UserSerializer, RegisterSerializer,
    LoginSerializer, ProfileUpdateSerializer,
)

# ── HELPER VALIDATIONS ──────────────────────────────────────────────

def is_password_strong(password):
    """Min 8 chars, 1 uppercase, 1 lowercase, 1 special character."""
    pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$'
    return re.match(pattern, password)

def is_allowed_email(email):
    """Restrict to gmail.com, yahoo.com, and hotmail.com."""
    allowed_domains = ('@gmail.com', '@yahoo.com', '@hotmail.com')
    return email.lower().endswith(allowed_domains)

# ── AUTH VIEWS ──────────────────────────────────────────────────────

@api_view(['POST'])
@permission_classes([AllowAny])
def register_view(request):
    email = request.data.get('email', '')
    password = request.data.get('password', '')

    # 1. Email Domain Check
    if not is_allowed_email(email):
        return Response({
            'detail': 'Invalid email domain. Use @gmail.com, @yahoo.com, or @hotmail.com.'
        }, status=status.HTTP_400_BAD_REQUEST)

    # 2. Password Strength Check
    if not is_password_strong(password):
        return Response({
            'detail': 'Password must be 8+ characters and include uppercase, lowercase, and a special character.'
        }, status=status.HTTP_400_BAD_REQUEST)

    serializer = RegisterSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    user = serializer.save()
    token, _ = Token.objects.get_or_create(user=user)
    return Response({
        'token': token.key,
        'user': UserSerializer(user).data,
    }, status=status.HTTP_201_CREATED)


@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    email = request.data.get('email', '')
    password = request.data.get('password', '')

    # Check Email and Password format before processing login
    if not is_allowed_email(email) or not is_password_strong(password):
        return Response({
            'detail': 'Invalid email or password format.'
        }, status=status.HTTP_400_BAD_REQUEST)

    serializer = LoginSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    user = serializer.validated_data['user']
    token, _ = Token.objects.get_or_create(user=user)
    return Response({
        'token': token.key,
        'user': UserSerializer(user).data,
    })

# ... (Rest of your views: logout, profile, stats remain the same)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_view(request):
    request.user.auth_token.delete()
    return Response({'detail': 'Logged out successfully'}, status=status.HTTP_200_OK)


@api_view(['GET', 'PUT'])
@permission_classes([IsAuthenticated])
def profile_view(request):
    if request.method == 'GET':
        return Response(UserSerializer(request.user).data)

    serializer = ProfileUpdateSerializer(request.user, data=request.data, partial=True)
    serializer.is_valid(raise_exception=True)
    serializer.save()
    return Response(UserSerializer(request.user).data)


class UserListView(generics.ListAPIView):
    """Admin-only: list all users with optional filters."""
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        from django.db.models import Q
        qs = User.objects.all().order_by('-date_joined')

        role = self.request.query_params.get('role')
        if role:
            qs = qs.filter(role=role)

        search = self.request.query_params.get('search')
        if search:
            qs = qs.filter(
                Q(name__icontains=search) |
                Q(email__icontains=search) |
                Q(district__icontains=search)
            )

        is_verified = self.request.query_params.get('is_verified')
        if is_verified is not None:
            qs = qs.filter(is_verified=is_verified.lower() == 'true')

        return qs


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def admin_stats_view(request):
    """Dashboard statistics for admin."""
    from products.models import Product
    from orders.models import Order

    total_users = User.objects.count()
    total_products = Product.objects.count()
    total_orders = Order.objects.count()
    total_revenue = Order.objects.filter(
        payment_status='paid'
    ).aggregate(total=Sum('total_amount'))['total'] or 0
    pending_orders = Order.objects.filter(status='pending').count()

    return Response({
        'total_users': total_users,
        'total_products': total_products,
        'total_orders': total_orders,
        'total_revenue': float(total_revenue),
        'pending_orders': pending_orders,
    })
import re  # 1. Import regular expressions at the top

# Helper function for validation
def is_password_strong(password):
    # Min 8 chars, 1 uppercase, 1 lowercase, 1 special character (!@#$%^&*)
    pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$'
    return re.match(pattern, password)

@api_view(['POST'])
@permission_classes([AllowAny])
def register_view(request):
    password = request.data.get('password', '')

    # 2. Add validation check
    if not is_password_strong(password):
        return Response({
            'detail': 'Password must be 8+ characters and include uppercase, lowercase, and a special character.'
        }, status=status.HTTP_400_BAD_REQUEST)

    serializer = RegisterSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    user = serializer.save()
    token, _ = Token.objects.get_or_create(user=user)
    return Response({
        'token': token.key,
        'user': UserSerializer(user).data,
    }, status=status.HTTP_201_CREATED)


@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    # Note: Usually, we only validate the format during Registration.
    # However, since you requested it for Login too:
    password = request.data.get('password', '')
    if not is_password_strong(password):
        return Response({
            'detail': 'Invalid password format.'
        }, status=status.HTTP_400_BAD_REQUEST)

    serializer = LoginSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    user = serializer.validated_data['user']
    token, _ = Token.objects.get_or_create(user=user)
    return Response({
        'token': token.key,
        'user': UserSerializer(user).data,
    })

