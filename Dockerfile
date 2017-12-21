
FROM php:7.1.5-apache

RUN apt-get update && \
    apt-get install -y \
        libxml2-dev \
        libpng12-dev \
        libjpeg-dev \
        zlib1g-dev libicu-dev git && \
        rm -rf /var/lib/apt/lists/*

# bcmath bz2 calendar ctype curl dba dom enchant exif
# fileinfo filter ftp gd gettext gmp hash iconv imap
# interbase intl json ldap mbstring mcrypt mysqli
# oci8 odbc opcache pcntl pdo pdo_dblib pdo_firebird pdo_mysql pdo_oci pdo_odbc pdo_pgsql pdo_sqlite pgsql phar posix pspell readline recode reflection session shmop simplexml snmp soap sockets spl standard sysvmsg sysvsem sysvshm tidy tokenizer wddx xml xmlreader xmlrpc xmlwriter xsl zip
RUN docker-php-ext-install \
    mysqli pdo_mysql zip

RUN docker-php-ext-install intl

RUN docker-php-ext-configure gd --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

RUN a2enmod rewrite

ADD docker/apache2/sites-enabled /etc/apache2/sites-enabled

RUN echo "log_errors = On\nerror_log = /dev/stderr" >> /usr/local/etc/php/php.ini

RUN apt-get update && \
    apt-get install -y ssmtp \
        mailutils && \
        rm -rf /var/lib/apt/lists/*

# set up sendmail config, see http://linux.die.net/man/5/ssmtp.conf for options
RUN echo "hostname=ssl.test" > /etc/ssmtp/ssmtp.conf
RUN echo "root=no-reply@ssl.test" >> /etc/ssmtp/ssmtp.conf
RUN echo "mailhub=smtp.ssl.test" >> /etc/ssmtp/ssmtp.conf

# Set up php sendmail config
RUN echo "sendmail_path=sendmail -i -t" >> /usr/local/etc/php/conf.d/php-sendmail.ini

RUN mkdir -p /opt/cert-monitor &&\
    touch /opt/cert-monitor/pre_checks.json &&\
    touch /opt/cert-monitor/checks.json &&\
    touch /opt/cert-monitor/deleted_checks.json &&\
    echo "[]" > /opt/cert-monitor/pre_checks.json &&\
    echo "[]" > /opt/cert-monitor/checks.json &&\
    echo "[]" > /opt/cert-monitor/deleted_checks.json &&\
    chown -R www-data:www-data /opt/cert-monitor

ADD ./ /var/www/html/

CMD ["apache2-foreground"]

