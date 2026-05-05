import os
from pathlib import Path
import pymysql
import dj_database_url  # You need to install this

# MySQL setup for Django
pymysql.version_info = (1, 4, 6, "final", 0)
pymysql.install_as_MySQLdb()

BASE_DIR = Path(__file__).resolve().parent.parent

# SECURITY: Use an environment variable for the key on Render
SECRET_KEY = os.environ.get('SECRET_KEY', 'django-insecure-agrilink-dev-key')

# SECURITY: Debug should be False in production
DEBUG = os.environ.get('DEBUG', 'True') == 'True'

ALLOWED_HOSTS = ['*'] # Render will handle the specific domain

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'rest_framework.authtoken',
    'corsheaders',
    'accounts',
    'products',
    'orders',
    'cart',
    'whitenoise.runserver_nostatic', # For serving static files on Render
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware', # Add this for static files
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# --- DATABASE CONFIGURATION ---
# This looks for 'DATABASE_URL' (your Aiven URI) on Render.
# If it doesn't find it, it falls back to your local XAMPP MySQL.
DATABASES = {
    'default': dj_database_url.config(
        default='mysql://root:@127.0.0.1:3307/agrilink_db'
    )
}
# --- STATIC FILES ---
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

TIME_ZONE = 'Asia/Dhaka'
USE_TZ = True
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'