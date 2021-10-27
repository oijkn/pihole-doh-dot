#!/bin/bash

# Install basic packages
apt-get -y update \
    && apt-get -y dist-upgrade \
    && apt-get -y install sudo bash nano wget dialog apt-utils
    
# Install Stubby
apt-get -y update \
    && apt-get -y install stubby

# Clean Stubby config
mkdir -p /etc/stubby \
    && rm -f /etc/stubby/stubby.yml

# Install Cloudflared - Method 1
#cd /tmp \
#    && wget https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-arm.tgz \
#    && tar -xvzf ./cloudflared-stable-linux-arm.tgz \
#    && cp ./cloudflared /usr/local/bin \
#    && rm -f ./cloudflared-stable-linux-arm.tgz

# Install Cloudflared - Method 2
cd /tmp \
    && wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm \
    && cp ./cloudflared-linux-arm /usr/local/bin/cloudflared \
    && chmod +x /usr/local/bin/cloudflared

useradd -s /usr/sbin/nologin -r -M cloudflared \
    && chown cloudflared:cloudflared /usr/local/bin/cloudflared
    
# Update Cloudflared to latest version
cloudflared update

# Clean Cloudflared config
mkdir -p /etc/cloudflared \
    && rm -f /etc/cloudflared/config.yml

# Clean up
apt-get -y autoremove \
    && apt-get -y autoclean \
    && apt-get -y clean \
    && rm -fr /tmp/* /var/tmp/* /var/lib/apt/lists/*

# Creating pihole-doh-dot service
mkdir -p /etc/services.d/pihole-doh-dot

# Backup original pihole www files
cd /var/www/html/admin/scripts/pi-hole/php/
cp header.php header.php.bak
cp footer.php footer.php.bak

# Modify pihole www files by Oijkn
sed -r -i 's#<title>Pi-hole#<title>Pi-hole DoH/DoT#g' header.php
sed -r -i 's#Pi-<strong>hole</strong>#Pi-<strong>hole</strong> DoH/DoT#g' header.php
sed -r -i 's#>Pi-hole<#>Pi-hole DoH/DoT<#g' header.php
sed -n -i 's#<strong>Docker Tag</strong> <?php echo $dockerTag; ?>#<strong>Docker Tag oijkn/pihole-doh-dot moded by <strong>Oijkn</strong>#g' footer.php

# Run file
echo '#!/usr/bin/with-contenv bash' > /etc/services.d/pihole-doh-dot/run

# Run Stubby in background
echo 's6-echo "Starting Stubby"' >> /etc/services.d/pihole-doh-dot/run
echo 'stubby -g -C /config/stubby.yml' >> /etc/services.d/pihole-doh-dot/run

# Run Cloudflared in foreground
echo 's6-echo "Starting Cloudflared"' >> /etc/services.d/pihole-doh-dot/run
echo '/usr/local/bin/cloudflared --config /config/cloudflared.yml' >> /etc/services.d/pihole-doh-dot/run

# Finish file
echo '#!/usr/bin/with-contenv bash' > /etc/services.d/pihole-doh-dot/finish
echo 's6-echo "Stopping Stubby"' >> /etc/services.d/pihole-doh-dot/finish
echo 'killall -9 stubby' >> /etc/services.d/pihole-doh-dot/finish
echo 's6-echo "Stopping Cloudflared"' >> /etc/services.d/pihole-doh-dot/finish
echo 'killall -9 cloudflared' >> /etc/services.d/pihole-doh-dot/finish
