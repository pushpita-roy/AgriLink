import os
import django

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'agrilink.settings')
django.setup()

from accounts.models import User

# Configuration - Change these to what you want!
USERNAME = 'admin'
EMAIL = 'admin@agrilink.com'
PASSWORD = '@Admin00' 

def create_superuser():
    try:
        if not User.objects.filter(username=USERNAME).exists():
            print(f"Creating superuser for {USERNAME}...")
            User.objects.create_superuser(
                username=USERNAME,
                email=EMAIL,
                password=PASSWORD
            )
            print("Superuser created successfully!")
        else:
            print(f"Superuser {USERNAME} already exists. Skipping.")
    except Exception as e:
        print(f"Error creating superuser: {e}")

if __name__ == "__main__":
    create_superuser()