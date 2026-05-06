import os
import django

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'agrilink.settings')
django.setup()

from accounts.models import User

# Configuration
USERNAME = 'admin'
EMAIL = 'admin@agrilink.com'
PASSWORD = '@Admin00' 

def create_superuser():
    try:
        # Check if user exists
        user = User.objects.filter(username=USERNAME).first()
        
        if not user:
            print(f"Creating superuser for {USERNAME}...")
            User.objects.create_superuser(
                username=USERNAME,
                email=EMAIL,
                password=PASSWORD,
                role='admin' # Sets the custom role for your app
            )
            print("Superuser created successfully!")
        else:
            print(f"Updating {USERNAME} to Superuser with Admin role...")
            user.role = 'admin'      # Fixes the label in your Flutter app
            user.is_staff = True     # Allows access to Django Admin
            user.is_superuser = True # Gives all permissions
            user.save()
            print("User updated to Superuser successfully!")
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    create_superuser()