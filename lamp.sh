#! /bin/bash

function hello {
    echo "Hello, $1!"
}

function update_system {
    export DEBIAN_FRONTEND=noninteractive
    apt-get update && apt-get upgrade -y
}

function update_hostname {
	HOSTNAME="$1"

	echo "$HOSTNAME" > /etc/hostname
	hostname -F /etc/hostname
}

function add_user {
	USERNAME="$1"
	USERPASS="$2"

	adduser $USERNAME --disabled-password --gecos ""
	echo "$USERNAME:$USERPASS" | chpasswd
	usermod -aG sudo $USERNAME
}

function add_pubkey {
	USERNAME="$1"
    PUBKEY="$2"

	mkdir -p /home/$USERNAME/.ssh
	echo "$PUBKEY" >> /home/$USERNAME/.ssh/authorized_keys
	chown -R "$USERNAME":"$USERNAME" /home/$USERNAME/.ssh
    chmod 600 /home/$USERNAME/.ssh/authorized_keys
}

function harden_ssh {
    sed -i -e "s/PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
    sed -i -e "s/#PasswordAuthentication no/PasswordAuthentication no/" /etc/ssh/sshd_config
	sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    systemctl restart sshd
}

function install_zip {
    apt-get install -y zip unzip
}

function install_fail2ban {
    apt-get install fail2ban -y
    cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local 
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local 
    systemctl start fail2ban
    systemctl enable fail2ban
}

function install_ufw {
    apt-get install ufw -y
    ufw default allow outgoing
    ufw default deny incoming
    ufw allow ssh
    ufw allow http
    ufw allow https
    ufw enable
    systemctl enable ufw
}

function install_apache {
    IPV4=$(hostname -I | cut -d ' ' -f 1)
    
    apt-get install -y apache2
    cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.orginal
    cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.original 

    sed -i -e "s/ Indexes / /" /etc/apache2/apache2.conf
    sed -ie "s/KeepAliveTimeout 5/KeepAliveTimeout 1/" /etc/apache2/apache2.conf

    mkdir -p /var/www/000-default
    sed -i -e "s/var\/www\/html/var\/www\/000-default/" /etc/apache2/sites-available/000-default.conf
    sed -i -e "s/www.example.com/$IPV4/" /etc/apache2/sites-available/000-default.conf
    sed -i -e "s/localhost/$IPV4/" /etc/apache2/sites-available/000-default.conf
    
    rm -r /var/www/html
    echo "<?php echo '$IPV4'; ?>" > /var/www/000-default/index.php

    a2enmod rewrite
   
    systemctl restart apache2 
}

function install_certbot {
    apt-get install -y software-properties-common
    add-apt-repository -y universe
    add-apt-repository -y ppa:certbot/certbot
    apt-get update
    apt-get install -y certbot python-certbot-apache 
}

function install_php {
    apt-get install -y php php-mysql php-mbstring php-curl php-json php-intl php-xml composer
}

function install_mysql {
    UN="$1"
    PW="$2"
  
    echo "mysql-server mysql-server/root_password password $PW" | debconf-set-selections  
    echo "mysql-server mysql-server/root_password_again password $PW" | debconf-set-selections  
    
    apt-get install -y mysql-server
    systemctl start mysql
    
    echo 'creating user for  mysql...'
    mysql -uroot -p$PW -e "GRANT ALL ON *.* to '$UN' IDENTIFIED BY '$PW'";

    echo 'restarting mysql...'
    systemctl restart mysql-server
}


function install_goaccess {
    apt-get install -y goaccess
}

function provision {
	HN="$1"
    UN="$2"
    PW="$3"
    PK="$4"

    echo "Provisioning...$HN"

    update_system
    update_hostname "$HN"
    add_user "$UN" "$PW"
    add_pubkey "$UN" "$PK"
    harden_ssh
    install_zip
    install_fail2ban
    install_ufw
    install_apache
    install_certbot
    install_php
    install_mysql "$UN" "$PW"
    
    echo "Rebooting..."
    reboot
}
