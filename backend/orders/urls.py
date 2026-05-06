from django.urls import path
from . import views

urlpatterns = [
    path('', views.OrderListView.as_view(), name='order-list'),
    path('place/', views.place_order_view, name='place-order'),
    path('stats/', views.order_stats_view, name='order-stats'), 
    path('<int:pk>/status/', views.update_order_status_view, name='update-order-status'),
]