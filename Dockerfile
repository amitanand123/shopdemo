FROM dockware/dev:6.5.2.1

COPY --chown=www-data:www-data docker/www/ /var/www
COPY --chown=www-data:www-data html/ /var/www/html


RUN sudo apt-get update \
    && sudo apt-get install dos2unix \
    && dos2unix /var/www/boot_end.sh \
    && dos2unix /var/www/html/files/setup/copyDbAndMedia.sh \
    && chmod 600 /var/www/.ssh/id_rsa \
    && sudo composer require shopware/dev-tools --working-dir /var/www/html #for installing the symfony toolbar

