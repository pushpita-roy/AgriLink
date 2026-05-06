#!/usr/bin/env bash
# exit on error
set -o errexit

pip install -r requirements.txt

# This forces Django to see the changes even if it's confused
python manage.py makemigrations accounts
python manage.py makemigrations products
python manage.py migrate --noinput

python manage.py collectstatic --noinput