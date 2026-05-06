#!/usr/bin/env bash
# Exit on error
set -o errexit

# Install dependencies
pip install -r requirements.txt

# Migrate the database
python manage.py migrate --noinput

# Collect static files for the Admin panel design
python manage.py collectstatic --noinput

# RUN YOUR ADMIN SCRIPT HERE
# (Make sure create_admin.py is in the same folder as manage.py)
python create_admin.py