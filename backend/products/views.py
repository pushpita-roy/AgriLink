from rest_framework import status, generics
from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.authentication import TokenAuthentication
from rest_framework.response import Response
from django.db.models import Q, Count

from .models import Product
from .serializers import ProductSerializer, ProductCreateUpdateSerializer

class ProductListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    authentication_classes = [TokenAuthentication] # FIX 1

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return ProductCreateUpdateSerializer
        return ProductSerializer

    def get_queryset(self):
        qs = Product.objects.select_related('farmer').all()
        search = self.request.query_params.get('search')
        if search:
            qs = qs.filter(
                Q(name__icontains=search) |
                Q(category__icontains=search) |
                Q(description__icontains=search)
            )
        category = self.request.query_params.get('category')
        if category and category != 'All':
            qs = qs.filter(category=category)
        farmer_id = self.request.query_params.get('farmer_id')
        if farmer_id:
            qs = qs.filter(farmer_id=farmer_id)
        min_price = self.request.query_params.get('min_price')
        if min_price:
            qs = qs.filter(price_per_unit__gte=min_price)
        max_price = self.request.query_params.get('max_price')
        if max_price:
            qs = qs.filter(price_per_unit__lte=max_price)
        in_stock = self.request.query_params.get('in_stock')
        if in_stock == 'true':
            qs = qs.filter(stock_qty__gt=0)
        elif in_stock == 'false':
            qs = qs.filter(stock_qty=0)
        sort = self.request.query_params.get('sort')
        if sort == 'name':
            qs = qs.order_by('name')
        elif sort == 'price_asc':
            qs = qs.order_by('price_per_unit')
        elif sort == 'price_desc':
            qs = qs.order_by('-price_per_unit')
        elif sort == 'rating':
            qs = qs.order_by('-rating')
        elif sort == 'stock':
            qs = qs.order_by('stock_qty')
        return qs

    def perform_create(self, serializer):
        serializer.save(farmer=self.request.user)

    def create(self, request, *args, **kwargs):
        if request.user.role != 'farmer':
            return Response(
                {'detail': 'Only farmers can add products.'},
                status=status.HTTP_403_FORBIDDEN,
            )
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        product = Product.objects.select_related('farmer').get(pk=serializer.instance.pk)
        return Response(
            ProductSerializer(product, context={'request': request}).data,
            status=status.HTTP_201_CREATED,
        )

class ProductDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Product.objects.select_related('farmer').all()
    permission_classes = [IsAuthenticated]
    authentication_classes = [TokenAuthentication] # FIX 2

    def get_serializer_class(self):
        if self.request.method in ('PUT', 'PATCH'):
            return ProductCreateUpdateSerializer
        return ProductSerializer

    def update(self, request, *args, **kwargs):
        product = self.get_object()
        if product.farmer != request.user and request.user.role != 'admin':
            return Response(
                {'detail': 'You can only edit your own products.'},
                status=status.HTTP_403_FORBIDDEN,
            )
        partial = kwargs.pop('partial', False)
        serializer = self.get_serializer(product, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        product.refresh_from_db()
        return Response(
            ProductSerializer(product, context={'request': request}).data,
        )

    def destroy(self, request, *args, **kwargs):
        product = self.get_object()
        if product.farmer != request.user and request.user.role != 'admin':
            return Response(
                {'detail': 'You can only delete your own products.'},
                status=status.HTTP_403_FORBIDDEN,
            )
        product.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

@api_view(['GET'])
@authentication_classes([TokenAuthentication]) # FIX 3
@permission_classes([IsAuthenticated])
def categories_view(request):
    cats = Product.objects.values_list('category', flat=True).distinct().order_by('category')
    return Response(['All'] + list(cats))

@api_view(['GET'])
@authentication_classes([TokenAuthentication]) # FIX 4
def popular_products_view(request):
    products = Product.objects.all()
    products = products.annotate(sales_count=Count('order_items')).order_by('-sales_count')[:10]
    serializer = ProductSerializer(products, many=True, context={'request': request})
    return Response(serializer.data)