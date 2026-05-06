from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.http import HttpResponse # Import this

# Add this small function
def home(request):
    return HttpResponse("<h1>AgriLink Backend is Live!</h1>")

urlpatterns = [
    path('', home), # Add this line for the homepage
    path('admin/', admin.site.urls),
    path('api/auth/', include('accounts.urls')),
    path('api/products/', include('products.urls')),
    path('api/orders/', include('orders.urls')),
    path('api/cart/', include('cart.urls')),
]

# This is correct - it keeps media working in local dev
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)