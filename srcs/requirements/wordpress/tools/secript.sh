#!/bin/bash

set -e

MYSQL_DATABASE="$(cat /run/secrets/mysql_database)"
MYSQL_USER="$(cat /run/secrets/mysql_user)"
MYSQL_PASSWORD="$(cat /run/secrets/databasepassword)"
WP_ADMIN_PASSWORD="$(cat /run/secrets/wp_admin_password)"
WP_USER_PASSWORD="$(cat /run/secrets/wp_user_password)"
until mysqladmin -h mariadb \
    -u "$MYSQL_USER" \
    -p"$MYSQL_PASSWORD" \
    ping --silent
do
  sleep 2
done

if [ ! -f /var/www/html/wp-config.php ]; then
  wp core download \
  --path=/var/www/html \
  --allow-root

  wp config create \
    --path=/var/www/html \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MYSQL_PASSWORD" \
    --dbhost=mariadb \
    --allow-root

  wp core install \
    --path=/var/www/html \
    --url="$DOMAIN_NAME" \
    --title="Inception" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --allow-root
  
  wp user create \
    "$WP_USER" \
    "$WP_USER_EMAIL" \
    --role=author \
    --user_pass="$WP_USER_PASSWORD" \
    --path=/var/www/html \
    --allow-root

fi

exec php-fpm8.2 -F


