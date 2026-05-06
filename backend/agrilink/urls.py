from django.contrib import admin
from django.urls import path, include, re_path # Added re_path
from django.conf import settings
from django.conf.urls.static import static
from django.http import HttpResponse
from django.views.static import serve # Added this

def home(request):
    return HttpResponse("<h1>AgriLink Backend is Live!</h1>")

urlpatterns = [
    path('', home),
    path('admin/', admin.site.urls),
    path('api/auth/', include('accounts.urls')),
    path('api/products/', include('products.urls')),
    path('api/orders/', include('orders.urls')),
    path('api/cart/', include('cart.urls')),
]

# 1. Keep local dev working
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

# 2. FIX: Force Render to serve media files
urlpatterns += [
    re_path(r'^media/(?P<path>.*)$', serve, {'document_root': settings.MEDIA_ROOT}),
]