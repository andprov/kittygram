# Kittygram

[![License MIT](https://img.shields.io/badge/licence-MIT-green)](https://opensource.org/license/mit/)
[![Code style black](https://img.shields.io/badge/code%20style-black-black)](https://github.com/psf/black)
[![Python versions](https://img.shields.io/badge/python-3.9%20%7C%203.10%20%7C3.11-blue)](#)
[![Django versions](https://img.shields.io/badge/Django-3.2-blue?logo=django)](#)
[![Nginx version](https://img.shields.io/badge/Nginx-1.22-blue?logo=nginx)](#)
[![Postgres version](https://img.shields.io/badge/PSQL-13-blue?logo=postgresql)](#)
[![Main Kittygram workflow](https://github.com/andprov/kittygram/actions/workflows/main.yml/badge.svg)](https://github.com/andprov/kittygram/actions/workflows/main.yml)

## Описание
- Проект Kittygram позволяет пользователям делиться своими фотографиями котиков и просматривать фотографии котиков других пользователей.
- При загрузке фото котика, пользователь должен ввести имя котика, год его рождения. При желании, может добавить ему достижения.
- Добавлять и просматривать фотографии могут только зарегистрированные и авторизованные пользователи.
- Только авторы могут изменять фотографии своих питомцев и описание.


## Необходимо для запуска
💡[Docker](https://docs.docker.com/engine/install/)

## Локальное развертывание
В процессе развертывания приложения запускается скрипт `backend/run-up.sh`,
который выполняет миграции, собирает и копирует статику backend приложения. 
Создает суперпользователя django.

💡Данные суперпользователя необходимо предварительно задать в `.env` файле.

Клонировать репозиторий:
```shell
git clone git clone <https or SSH URL>
```
Перейти в каталог проекта:
```shell
cd kittygram
```

Создать .env файл со следующим содержанием:
```shell
# DB
POSTGRES_USER=<user>
POSTGRES_PASSWORD=<password>
POSTGRES_DB=<db_name>
DB_HOST=db
DB_PORT=5432

# Django settings
SECRET_KEY=<django_secret_key>
DEBUG=False
ALLOWED_HOSTS=127.0.0.1;localhost;<example.com;xxx.xxx.xxx.xxx>

# Superuser data
ADMIN_USERNAME=<username>
ADMIN_EMAIL=<example>@<example.com>
ADMIN_PASSWORD=<password>
```
Развернуть приложение:
```shell
sudo docker compose -f docker-compose.dev.yml up
```
После успешного запуска, проект доступен на локальном IP `127.0.0.1:9000`.

## Развертывание на удаленном сервере
Для развертывания на удаленном сервере необходимо клонировать репозиторий на локальную машину. Подготовить и загрузить образы на Docker Hub.

Клонировать репозиторий:
```shell
git clone git clone <https or SSH URL>
```
Перейти в каталог проекта:
```shell
cd kittygram
```

Создать docker images образы:
```shell
sudo docker build -t <username>/kittygram_backend backend/
sudo docker build -t <username>/kittygram_frontend frontend/
sudo docker build -t <username>/kittygram_gateway nginx/
```
Загрузить образы на Docker Hub:
```shell
sudo docker push <username>/kittygram_backend
sudo docker push <username>/kittygram_frontend
sudo docker push <username>/kittygram_gateway
```
Создать .env файл со следующим содержанием:
```shell
# DB
POSTGRES_USER=<user>
POSTGRES_PASSWORD=<password>
POSTGRES_DB=<db_name>
DB_HOST=db
DB_PORT=5432

# Django settings
SECRET_KEY=<django_secrt_key>
DEBUG=False
ALLOWED_HOSTS=127.0.0.1;localhost;<example.com;xxx.xxx.xxx.xxx>

# Docker images 
BACKEND_IMAGE=<username>/kittygram_backend
FRONTEND_IMAGE=<username>/kittygram_frontend
GATEWAY_IMAGE=<username>/kittygram_gateway
```

💡 Дальнейшая инструкция предполагает, что удаленный сервер настроен на работу по `SSH`.
На сервере установлен Docker. Установлен и настроен nginx в качестве балансировщика 
нагрузки.

Перенести на удаленный сервер файлы `.env` `docker-compose.production.yml`:
```shell
scp .env docker-compose.production.yml <username>@<server_address>:/home/<username>/kittygram
```
Подключиться к серверу:
```shell
ssh <username>@<server_address>
```
Перейти в директорию `kittygram`:
```shell
cd /home/<username>/kittygram
```
Выполнить сборку приложений:
```shell
sudo docker compose -f docker-compose.production.yml up -d
```
Выполнить миграции:
```shell
sudo docker compose -f docker-compose.production.yml exec backend python manage.py migrate
```
Собрать статику:
```shell
sudo docker compose -f docker-compose.production.yml exec backend python manage.py collectstatic
```
Скопировать статику:
```shell
sudo docker compose -f docker-compose.production.yml exec backend cp -r /app/collected_static/. web/backend_static/static
```
Настроить шлюз для перенаправления запросов на `9000` порт, который слушает контейнер `kittygram_gateway`
```shell
sudo  vi /etc/nginx/sites-enabled/default
```
Пример конфигурации Nginx:
```shell
server {
    server_name example.com;

    location / {
        client_max_body_size 20M;
        proxy_pass http://127.0.0.1:9000;
    }

    listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}

server {
    if ($host = example.com) {
        return 301 https://$host$request_uri;
    }

    listen 80;
    return 404;
    server_name example.com;
}
```

Перезапустить nginx:
```shell
sudo systemctl restart nginx.service
```

## GitHub Actions
Для использования автоматизированного развертывания и тестирования нужно 
изменить `.github/workflows/main.yml` под свои параметры и аккаунт.

Actions secrets:
- `secrets.DOCKER_USERNAME`
- `secrets.DOCKER_PASSWORD`
- `secrets.HOST`
- `secrets.USER`
- `secrets.SSH_KEY`
- `secrets.SSH_PASSPHRASE`
- `secrets.TELEGRAM_TO`
- `secrets.TELEGRAM_TOKEN`