docker run -d \
    --hostname='rpi-srv' \
    --name='pihole-doh-dot' \
    --cap-add=NET_ADMIN \
    --restart=unless-stopped \
    --net='bridge' \
    --env-file ./config/.env \
    -v '/data/pihole-doh-dot/pihole/':'/etc/pihole/':'rw' \
    -v '/data/pihole-doh-dot/dnsmasq.d/':'/etc/dnsmasq.d/':'rw' \
    -v '/data/pihole-doh-dot/config/':'/config':'rw' \
    -p '53:53/tcp' \
    -p '53:53/udp' \
    -p '67:67/udp' \
    -p '1010:80/tcp' \
    -p '443:443/tcp' \
    'oijkn/pihole-doh-dot:latest'
