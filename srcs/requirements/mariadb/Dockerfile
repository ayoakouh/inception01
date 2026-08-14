FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server && rm -rf /var/lib/apt/lists /var/lib/mysql/*

COPY tools/script.sh /script.sh

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf

RUN chmod +x /script.sh

EXPOSE 3306

ENTRYPOINT ["./script.sh"]





RUN chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf