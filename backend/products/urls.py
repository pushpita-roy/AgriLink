from django.urls import path
from . import views

urlpatterns = [
    path('', views.ProductListCreateView.as_view(), name='product-list-create'),
    path('<int:pk>/', views.ProductDetailView.as_view(), name='product-detail'),
    path('categories/', views.categories_view, name='product-categories'),
    path('popular/', views.popular_products_view, name='product-popular'),
]
