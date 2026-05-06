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
DEBUG = False

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
# --- DATABASE CONFIGURATION ---
# 1. Clear the config
db_config = dj_database_url.config(
    default=os.environ.get('DATABASE_URL'),
    conn_max_age=600,
)

# 2. Fix the "sslmode" and SSL errors for Aiven/MySQL
if db_config:
    # Remove the 'ssl_require' or 'sslmode' that causes the crash
    db_config.pop('ssl_require', None)
    db_config.pop('sslmode', None)
    
    # Add the specific SSL format MySQL requires
    if not DEBUG:
        db_config['OPTIONS'] = {
            'ssl': {'ca': None}
        }

DATABASES = {'default': db_config}
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

# Use the custom user model from the accounts app
AUTH_USER_MODEL = 'accounts.User'

# --- STATIC FILES ---
STATIC_URL = '/static/'
# This ensures it finds the folder correctly on Render's Linux server
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

# Use this specific WhiteNoise storage to avoid "Missing Manifest" 500 errors
STATICFILES_STORAGE = 'whitenoise.storage.CompressedStaticFilesStorage'

# --- REST FRAMEWORK SETTINGS ---
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
}

CORS_ALLOW_HEADERS = [
    "accept",
    "authorization",
    "content-type",
    "user-agent",
    "x-csrftoken",
    "x-requested-with",
]