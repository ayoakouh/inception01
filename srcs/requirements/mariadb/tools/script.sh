#!/bin/bash

set -e

if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
fi
# MYSQL_DATABASE="$(cat ../../../.env/ | grep MYSQL_DATABASE=)"
MY_SQL_ROOT_PASSWORD="$(cat /run/secrets/my_sql_rootpassword)"
DB_PASS="$(cat /run/secrets/databasepassword)"

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
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MY_SQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES
EOF

    mysqladmin -u root -p"${MY_SQL_ROOT_PASSWORD}" shutdown;
    sleep 2
fi


exec mysqld_safe --datadir=/var/lib/mysql

























































# # # Required environment variables
# DB_NAME=${DB_NAME:-wordpress}
# DB_USER=${DB_USER:-wp_user}
# DB_PASS=${DB_PASS:-password}
# DB_ROOT_PASS=${DB_ROOT_PASS:-root_password}

# # Create runtime directories
# mkdir -p /var/run/mysqld
# mkdir -p /var/lib/mysql
# chown -R mysql:mysql /var/run/mysqld
# chown -R mysql:mysql /var/lib/mysql





# # Initialize database if not already exists
# if [ ! -d "/var/lib/mysql/mysql" ]; then
#     mysql_install_db --user=mysql --datadir=/var/lib/mysql
# fi

# # Start MariaDB temporarily
# mysqld_safe --skip-networking --user=mysql &
# sleep 2

# # Wait for MariaDB to be ready
# while ! mysqladmin ping --silent; do
#     sleep 1
# done

# # Set root password
# mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';"

# # Create database, user, and grant privileges
# mysql -u root -p"${DB_ROOT_PASS}" -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
# mysql -u root -p"${DB_ROOT_PASS}" -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';"
# mysql -u root -p"${DB_ROOT_PASS}" -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';"
# mysql -u root -p"${DB_ROOT_PASS}" -e "FLUSH PRIVILEGES;"

# # Shutdown temporary instance
# mysqladmin -u root -p"${DB_ROOT_PASS}" shutdown

# # Start MariaDB in foreground (keeps container alive)
# exec mysqld_safe --user=mysql