#!/bin/bash

# This script is a hook and will be called by dockware entrypoint-script after initialization
# If it is located in /var/www
# https://github.com/dockware/dockware/blob/16558ab8464d55f453cd067be9522ca78de34d91/template/entrypoint.global.sh.twig#L220
echo ''
echo ' _    _     ______     ______      _   __'
echo '| |  | |    | ___ \    |  ___|    | | / /'
echo '| |  | |    | |_/ /    | |_       | |/ / '
echo '| |/\| |    | ___ \    |  _|      |    \ '
echo '\  /\  /___ | |_/ /    | |        | |\  \'
echo ' \/  \/  _ \|____/     |_|        \_| \_/'
echo '     |   __/                             '
echo '      \____\                             '
echo ''


cd "$(dirname "$0")/html/files/setup" || exit


# Only install Production-Dump on first startup.
CONTAINER_FIRST_STARTUP="CONTAINER_FIRST_STARTUP"
if [ ! -e $CONTAINER_FIRST_STARTUP ]; then
  echo "Initialize WBFK Shop ...please wait...\n\n"
  touch $CONTAINER_FIRST_STARTUP
else
  exit 0
fi

# Set execution-flag to sh scripts
chmod +x /var/www/html/files/setup/copyDbAndMedia.sh
chmod +x /var/www/html/bin/*.sh


# We copied the ".ssh" folder from host.
# Fix the access rights
chmod 644 /var/www/.ssh/*
chmod 600 /var/www/.ssh/id_rsa
chmod 600 /var/www/.ssh/PuttyGen.ppk
chmod 700 /var/www/.ssh

chmod +x /var/www/html/bin/*.sh

# sudo -u www-data sh -c "/var/www/html/files/setup/copyDbAndMedia.sh -f --copy_progress"

