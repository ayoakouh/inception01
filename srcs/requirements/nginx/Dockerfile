FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y nginx openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /etc/nginx/ssl

    
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/c=/MA/ST=Beni Mellal-khenifra/L=Khouribga/0=42/OU/1337/CN=ayoakouh.42.fr"




COPY conf/nginx.conf /etc/nginx/conf.d/nginx.conf
RUN chmod +x /etc/nginx/conf.d/nginx.conf

CMD ["nginx", "-g", "daemon off;"]