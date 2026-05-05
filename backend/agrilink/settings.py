import os
from pathlib import Path
import pymysql
import dj_database_url

# MySQL setup for Django
pymysql.version_info = (1, 4, 6, "final", 0)
pymysql.install_as_MySQLdb()

BASE_DIR = Path(__file__).resolve().parent.parent

# --- SECURITY ---
SECRET_KEY = os.environ.get('SECRET_KEY', 'django-insecure-agrilink-dev-key')

# Debug should be False in production (Render)
DEBUG = os.environ.get('DEBUG', 'False') == 'True'

# Allow Render domains and local testing
ALLOWED_HOSTS = ['localhost', '127.0.0.1', '.onrender.com']

# --- APPS ---
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'whitenoise.runserver_nostatic', # Static files
    'django.contrib.staticfiles',
    'rest_framework',
    'rest_framework.authtoken',
    'corsheaders',
    'accounts',
    'products',
    'orders',
    'cart',
]

# --- MIDDLEWARE ---
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware', # Must be at the top
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware', # For Render static files
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'agrilink.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'agrilink.wsgi.application'

# --- DATABASE CONFIGURATION ---
# Uses DATABASE_URL from Render (Aiven) or local XAMPP if URL is missing
DATABASES = {
    'default': dj_database_url.config(
        default='mysql://root:@127.0.0.1:3307/agrilink_db',
        conn_max_age=600,
        ssl_require=True if os.environ.get('DATABASE_URL') else False
    )
}

# --- CORS SETTINGS (For Flutter APK) ---
CORS_ALLOW_ALL_ORIGINS = True 

# --- STATIC FILES ---
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# --- MEDIA FILES ---
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# --- REGIONAL ---
TIME_ZONE = 'Asia/Dhaka'
USE_TZ = True
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'