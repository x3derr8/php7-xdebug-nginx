FROM ubuntu:14.04
MAINTAINER x3derr8@medianova.hr

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# PHP 7
RUN apt-get update && apt-get install -y software-properties-common \
  && apt-add-repository ppa:ondrej/php-7.0 && apt-get purge -y software-properties-common \
  && apt-get update \
  && apt-get install -y nginx-light php7.0-fpm php-xdebug supervisor \
  && apt-get clean
RUN mkdir -p /run/php
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/7.0/fpm/php.ini
RUN echo 'fastcgi_read_timeout 7200s;' >> /etc/nginx/fastcgi_params
COPY php.ini /etc/php/7.0/fpm/php.ini
COPY xdebug.ini /etc/php/mods-available/xdebug.ini

# Nginx
RUN { echo 'daemon off;'; cat /etc/nginx/nginx.conf; } > /tmp/nginx.conf && mv /tmp/nginx.conf /etc/nginx/nginx.conf
COPY nginx-site.conf /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Composer
RUN php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/local/bin --filename=composer

# 
EXPOSE 80
WORKDIR /srv
CMD ["/usr/bin/supervisord"]