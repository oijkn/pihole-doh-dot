# Welcome to Pi-hole DoH/DoT !

## 💻 Introduction

Official Pi-hole docker with both DoH (DNS over HTTPS) and DoT (DNS over TLS) clients.
Don't browse the Internet insecurely by sending your DNS requests in clear text !

Image built for Raspberry Pi (arm32/v7).

## 🚀 Installation

**1. Clone the repository**

`# git clone https://github.com/oijkn/pihole-doh-dot.git /path/of/your/docker/pihole`

**2. Edit environment files to fit your needs**

For docker parameters, refer to [official pihole docker readme](https://github.com/pi-hole/pi-hole).

`# cat /path/of/your/docker/pihole/config/.env`
```
TZ=Europe/Paris                             # Set your timezone to make sure logs rotate at local midnight instead of at UTC midnight.
WEBPASSWORD=password                        # Set your password to access Web UI
ServerIP=0.0.0.0                            # Set to your server's LAN IP, used by web block modes and lighttpd bind address
VIRTUAL_HOST=192.168.1.100                  # What your web server 'virtual host' is, accessing admin through this Hostname/IP allows you to make changes to the whitelist / blacklists in addition to the default 'http://pi.hole/admin/' address
PIHOLE_DNS_=127.0.0.1#5053;127.0.0.1#5153   # Upstream DNS server(s) for Pi-hole to forward queries to, seperated by a semicolon (supports non-standard ports with #[port number]) e.g 127.0.0.1#5053;8.8.8.8;8.8.4.4
IPv6=false                                  # For unraid compatibility, strips out all the IPv6 configuration from DNS/Web services when false.
DNSMASQ_LISTENING=all                       # local listens on all local subnets, all permits listening on internet origin subnets in addition to local, single listens only on the interface specified.
PIHOLE_DOMAIN=home                          # Domain name sent by the DHCP server.
DNSMASQ_USER=root                           # Allows running FTLDNS as non-root.
```

## ☕ Docker usage

Consider changing the mounting point of the volume according to your needs.

```
docker run -d \
    --hostname='rpi-srv' \
    --name='pihole-doh-dot' \
    --cap-add=NET_ADMIN \
    --restart=unless-stopped \
    --net='bridge' \
    --env-file .env \
    -v '/data/pihole-doh-dot/pihole/':'/etc/pihole/':'rw' \
    -v '/data/pihole-doh-dot/dnsmasq.d/':'/etc/dnsmasq.d/':'rw' \
    -v '/data/pihole-doh-dot/config/':'/config':'rw' \
    -p '53:53/tcp' \
    -p '53:53/udp' \
    -p '67:67/udp' \
    -p '1010:80/tcp' \
    -p '443:443/tcp' \
    'oijkn/pihole-doh-dot:latest'
```

## 📝 Notes

- To use just DoH or just DoT service, set `PIHOLE_DNS_` to the same value.
 - DoH service (cloudflared) runs at 127.0.0.1#5053. Uses cloudflare (1.1.1.1 / 1.0.0.1) by default
 - DoT service (stubby) runs at 127.0.0.1#5153. Uses cloudflare (1.1.1.1 / 1.0.0.1) by default

- In addition to the 2 official paths, you can also map container /config to expose configuration yml files for cloudflared (cloudflared.yml) and stubby (stubby.yml).
 - Edit these files to add / remove services as you wish. The flexibility is yours.

## 📫 Credits

- Pihole (buster) base image is the official [pihole/pihole](https://hub.docker.com/r/pihole/pihole)
- Cloudflared client was obtained from [official site](https://developers.cloudflare.com/)
- Stubby is a standard debian buster [package](https://github.com/getdnsapi/stubby)
- Base script code from [https://github.com/testdasi](https://github.com/testdasi)
