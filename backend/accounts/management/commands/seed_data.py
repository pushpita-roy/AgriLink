from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import date

from accounts.models import User
from products.models import Product
from orders.models import Order, OrderItem


class Command(BaseCommand):
    help = 'Seed the database with demo data matching the Flutter app'

    def handle(self, *args, **options):
        self.stdout.write('Seeding database...')

        # ── Users ──────────────────────────────────────────────────────
        farmer, _ = User.objects.get_or_create(
            email='farmer@gmail.com',
            defaults={
                'username': 'farmer@gmail.com',
                'name': 'Rafique',
                'role': 'farmer',
                'phone': '01712345678',
                'address': 'Madhupur',
                'district': 'Tangail',
                'farm_name': "Rafique's Farm",
                'is_verified': True,
            },
        )
        farmer.set_password('123456')
        farmer.save()

        buyer, _ = User.objects.get_or_create(
            email='buyer@gmail.com',
            defaults={
                'username': 'buyer@gmail.com',
                'name': 'Kalua',
                'role': 'buyer',
                'phone': '01812345678',
                'address': 'Bhanga',
                'district': 'Faridpur',
                'is_verified': True,
            },
        )
        buyer.set_password('123456')
        buyer.save()

        admin_user, _ = User.objects.get_or_create(
            email='admin@gmail.com',
            defaults={
                'username': 'admin@gmail.com',
                'name': 'Admin',
                'role': 'admin',
                'phone': '01612345678',
                'address': 'Dhaka',
                'district': 'Dhaka',
                'is_verified': True,
                'is_staff': True,
                'is_superuser': True,
            },
        )
        admin_user.set_password('admin123')
        admin_user.save()

        self.stdout.write(self.style.SUCCESS('  ✓ Users created'))

        # ── Products ───────────────────────────────────────────────────
        products_data = [
            {
                'name': 'Rice Seed',
                'category': 'Seeds',
                'description': 'Premium quality rice seed for the season. Grown organically.',
                'unit_type': 'kg',
                'price_per_unit': 55,
                'stock_qty': 50,
                'location': 'Madhupur, Tangail',
                'harvest_date': date(2025, 5, 25),
                'image_url': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400',
                'rating': 4.8,
            },
            {
                'name': 'Lemon',
                'category': 'Fruits',
                'description': 'Fresh lemons from Tangail. Perfect for cooking and drinks.',
                'unit_type': 'kg',
                'price_per_unit': 14,
                'stock_qty': 30,
                'location': 'Madhupur, Tangail',
                'harvest_date': date(2025, 5, 20),
                'image_url': 'https://images.unsplash.com/photo-1590502593747-42a996133562?w=400',
                'rating': 4.5,
            },
            {
                'name': 'Wheat Seed',
                'category': 'Seeds',
                'description': 'High-yield wheat seed variety suitable for all soil types.',
                'unit_type': 'kg',
                'price_per_unit': 30,
                'stock_qty': 80,
                'location': 'Madhupur, Tangail',
                'harvest_date': date(2025, 5, 15),
                'image_url': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400',
                'rating': 4.7,
            },
            {
                'name': 'Cherry',
                'category': 'Fruits',
                'description': 'Sweet red cherries freshly picked from the orchard.',
                'unit_type': 'kg',
                'price_per_unit': 14,
                'stock_qty': 20,
                'location': 'Madhupur, Tangail',
                'harvest_date': date(2025, 5, 18),
                'image_url': 'https://images.unsplash.com/photo-1528821128474-27f963b062bf?w=400',
                'rating': 4.6,
            },
            {
                'name': 'Chilli',
                'category': 'Vegetables',
                'description': 'Spicy green and red chillies, organically grown.',
                'unit_type': 'kg',
                'price_per_unit': 14,
                'stock_qty': 40,
                'location': 'Madhupur, Tangail',
                'harvest_date': date(2025, 5, 22),
                'image_url': 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=400',
                'rating': 4.3,
            },
            {
                'name': 'Mango',
                'category': 'Fruits',
                'description': 'Langra variety mangoes, sweet and juicy.',
                'unit_type': 'kg',
                'price_per_unit': 40,
                'stock_qty': 60,
                'location': 'Madhupur, Tangail',
                'harvest_date': date(2025, 5, 10),
                'image_url': 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=400',
                'rating': 4.9,
            },
        ]

        created_products = []
        for pdata in products_data:
            product, _ = Product.objects.get_or_create(
                name=pdata['name'],
                farmer=farmer,
                defaults=pdata,
            )
            created_products.append(product)

        self.stdout.write(self.style.SUCCESS('  ✓ Products created'))

        # ── Demo Orders ────────────────────────────────────────────────
        if not Order.objects.exists():
            order1 = Order.objects.create(
                buyer=buyer,
                total_amount=550,
                status='delivered',
                payment_status='paid',
                shipping_address='Bhanga, Faridpur',
            )
            OrderItem.objects.create(
                order=order1,
                product=created_products[0],  # Rice Seed
                farmer=farmer,
                product_name='Rice Seed',
                unit_price=55,
                quantity=10,
            )

            order2 = Order.objects.create(
                buyer=buyer,
                total_amount=120,
                status='pending',
                shipping_address='Bhanga, Faridpur',
            )
            OrderItem.objects.create(
                order=order2,
                product=created_products[5],  # Mango
                farmer=farmer,
                product_name='Mango',
                unit_price=40,
                quantity=3,
            )
            self.stdout.write(self.style.SUCCESS('  ✓ Demo orders created'))

        self.stdout.write(self.style.SUCCESS('Done! Database seeded successfully.'))
        self.stdout.write('')
        self.stdout.write('Demo credentials:')
        self.stdout.write('  Farmer: farmer@gmail.com / 123456')
        self.stdout.write('  Buyer:  buyer@gmail.com  / 123456')
        self.stdout.write('  Admin:  admin@gmail.com  / admin123')
