#start fpm
rc-service php-fpm7 start

#start ngix
nginx -g 'daemon off;'
