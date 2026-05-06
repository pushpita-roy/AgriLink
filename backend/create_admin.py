import os
import django

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'agrilink.settings')
django.setup()

from accounts.models import User

# Configuration
USERNAME = 'admin'
EMAIL = 'admin@agrilink.com'
PASSWORD = '@Superuser0'  # FIXED: Added quotes around the password

def create_superuser():
    try:
        user = User.objects.filter(username=USERNAME).first()
        
        if not user:
            print(f"Creating superuser for {USERNAME}...")
            User.objects.create_superuser(
                username=USERNAME,
                email=EMAIL,
                password=PASSWORD,
                role='admin'
            )
            print("Superuser created successfully!")
        else:
            print(f"Updating {USERNAME} to Superuser with Admin role...")
            user.role = 'admin'
            user.is_staff = True
            user.is_superuser = True
            user.save()
            print("User updated to Superuser successfully!")
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    create_superuser()