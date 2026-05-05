from django.urls import path
from . import views

urlpatterns = [
    path('', views.cart_list_view, name='cart-list'),
    path('add/', views.cart_add_view, name='cart-add'),
    path('<int:pk>/update/', views.cart_update_view, name='cart-update'),
    path('<int:pk>/remove/', views.cart_remove_view, name='cart-remove'),
    path('clear/', views.cart_clear_view, name='cart-clear'),
]
