#!/bin/bash

#########################################
##       ENVIRONMENTAL CONFIG          ##
#########################################

# Configure user permissions on config directories
mkdir -p /config /startup /home/nobody
chown -R nobody:users /config /startup /home/nobody


#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################


# Install locales and upgrade
apt-get update -qq && apt-get upgrade -qy
apt-get install apt-utils wget locales -qy
update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX
locale-gen en_US.UTF-8
dpkg-reconfigure locales

#########################################
## FILES, SERVICES AND CONFIGURATION   ##
#########################################

# Add Supervisor config
cat <<'EOT' > /etc/supervisor.conf
[supervisord]
logfile=/config/supervisord.log
logfile_maxbytes=10MB
logfile_backups=3
loglevel=debug
nodaemon=true

[include]
files = /etc/supervisor/conf.d/*.conf
EOT

# Add base startup script
cat <<'EOT' > /startup/00_startup.sh
/startup/01_startup.sh



/startup/10_startup.sh
EOT

# Add user permssion startup script
cat <<'EOT' > /startup/01_startup.sh
#!/bin/bash

AUSER=${AUSER:-65534}
AGROUP=${AGROUP:-100}

if [ ! "$(id -u nobody)" -eq "$AUSER" ]; then
  usermod -o -u "$AUSER" nobody
fi
if [ ! "$(getent group users | cut -d: -f3)" -eq "$AGROUP" ]; then
  usermod -g "$AGROUP" nobody
fi

usermod -d /home/nobody nobody
EOT

# Add Supervisor startup
cat <<'EOT' > /startup/10_startup.sh
supervisord -c /etc/supervisor.conf -n
EOT

# Make startup scripts executable
chmod -R +x /startup/

#########################################
##             INTALLATION             ##
#########################################

# Download Pipework
wget -O /usr/local/bin/pipework https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework
chmod +x /usr/local/bin/pipework

# Install Supervisor
apt-get install supervisor -qy
mkdir -p /var/log/supervisor
mkdir -p /etc/supervisor/conf.d


#########################################
##              CLEANUP                ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
