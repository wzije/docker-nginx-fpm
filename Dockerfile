FROM alpine:3.10
LABEL maintainer="Jehan<jee.archer@gmail.com>"

# Install packages
RUN apk --no-cache add php7 php7-fpm php7-mysqli php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype \
    php7-mcrypt php7-dom php7-simplexml php7-fileinfo php7-tokenizer php7-xmlwriter php7-session \
    php7-mbstring php7-gd php7-pdo_mysql nginx supervisor curl nano \
    libgcc libstdc++ libx11 glib libxrender libxext libintl \
    ttf-dejavu ttf-droid ttf-freefont ttf-liberation ttf-ubuntu-font-family gcompat

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

#COPY config/default.conf /etc/nginx/conf.d/default.conf

# Configure PHP-FPM COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/zzz_custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document nobody
RUN mkdir -p /var/www/html

RUN mkdir -p /run/nginx

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/tmp/nginx && \
  chown -R nobody.nobody /var/log && \
  chown -R nobody.nobody /var/www/html

# Switch to use a non-root user from here on
USER nobody

# Add application
WORKDIR /var/www/html
COPY --chown=nobody ./ /var/www/html 

#set home
RUN HOME=/var/www/html

# Expose the port nginx is reachable on
EXPOSE 80

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1/fpm-ping
