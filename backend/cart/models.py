from django.db import models
from django.conf import settings


class CartItem(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='cart_items',
    )
    product = models.ForeignKey(
        'products.Product',
        on_delete=models.CASCADE,
        related_name='cart_entries',
    )
    quantity = models.PositiveIntegerField(default=1)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'cart_items'
        unique_together = ['user', 'product']

    def __str__(self):
        return f"{self.user.name} - {self.product.name} x{self.quantity}"

    @property
    def line_total(self):
        return self.product.price_per_unit * self.quantity
