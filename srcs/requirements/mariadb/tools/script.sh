#!/bin/bash

set -e

MYSQL_USER="$(cat /run/secrets/mysql_user)"
MYSQL_ROOT_PASSWORD="$(cat /run/secrets/my_sql_rootpassword)"
DB_PASS="$(cat /run/secrets/databasepassword)"
MYSQL_DATABASE="$(cat /run/secrets/mysql_database)"

chown -R mysql:mysql /var/lib/mysql 
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "mysql is not intialized database;"
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    mysqld_safe &

    until mariadb-admin ping --silent; do
        sleep 1
    done

mariadb -u root << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown;
    sleep 2
fi

exec mysqld_safe --datadir=/var/lib/mysql