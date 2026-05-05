from django.db import models
from django.conf import settings


class Product(models.Model):
    UNIT_CHOICES = [
        ('kg', 'Kilogram'),
        ('liter', 'Liter'),
        ('dozen', 'Dozen'),
        ('crate', 'Crate'),
        ('bundle', 'Bundle'),
        ('piece', 'Piece'),
    ]

    farmer = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='products',
    )
    name = models.CharField(max_length=200)
    category = models.CharField(max_length=100, blank=True, default='')
    description = models.TextField(blank=True, default='')
    unit_type = models.CharField(max_length=20, choices=UNIT_CHOICES, default='kg')
    price_per_unit = models.DecimalField(max_digits=10, decimal_places=2)
    stock_qty = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    location = models.CharField(max_length=255, blank=True, default='')
    harvest_date = models.DateField(blank=True, null=True)
    image = models.ImageField(upload_to='products/', blank=True, null=True)
    image_url = models.URLField(max_length=500, blank=True, default='')
    rating = models.DecimalField(max_digits=3, decimal_places=1, default=0.0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'products'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.name} by {self.farmer.name}"
