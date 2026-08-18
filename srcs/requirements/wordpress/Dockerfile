FROM debian:bookworm

RUN apt-get update && apt-get install -y php-fpm\
    php-cli \
    php-mysql \
    mariadb-client \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
    
    
RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 0.0.0.0:9000|g' \
/etc/php/8.2/fpm/pool.d/www.conf

RUN curl -L -o /usr/local/bin/wp \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp
COPY tools/script.sh  /script.sh
RUN chmod +x /script.sh
    
WORKDIR /var/www/html
 
EXPOSE 9000
    
ENTRYPOINT ["/script.sh"]
    
#mariadb-server \