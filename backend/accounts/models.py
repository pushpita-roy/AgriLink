from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    ROLE_CHOICES = [
        ('buyer', 'Buyer'),
        ('farmer', 'Farmer'),
        ('admin', 'Admin'),
    ]

    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='buyer')
    phone = models.CharField(max_length=20, blank=True, default='')
    address = models.CharField(max_length=255, blank=True, default='')
    district = models.CharField(max_length=100, blank=True, default='')
    division = models.CharField(max_length=50, blank=True, null=True)
    farm_name = models.CharField(max_length=200, blank=True, null=True)
    is_verified = models.BooleanField(default=False)

    # Use email as the display name; username is still required by AbstractUser
    name = models.CharField(max_length=200, blank=True, default='')

    class Meta:
        db_table = 'users'

    def __str__(self):
        return f"{self.name or self.username} ({self.role})"
