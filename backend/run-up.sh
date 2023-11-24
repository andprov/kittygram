#!/bin/bash

ADMIN_USERNAME=$ADMIN_USERNAME
ADMIN_EMAIL=$ADMIN_EMAIL
ADMIN_PASSWORD=$ADMIN_PASSWORD

python manage.py migrate
python manage.py collectstatic
cp -r /app/collected_static/. web/backend_static/static
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('$ADMIN_USERNAME', '$ADMIN_EMAIL', '$ADMIN_PASSWORD')" | python manage.py shell
gunicorn --bind 0.0.0.0:8000 kittygram_backend.wsgi