#!/usr/bin/env bash
set -o errexit

pip install -r requirements.txt

# Apply the migrations you just pushed
python manage.py migrate --noinput

# Force sync any missing tables (like the Token table for Auth)
python manage.py migrate --run-syncdb

python manage.py collectstatic --noinput