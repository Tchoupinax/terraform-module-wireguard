#!/bin/bash 

# https://www.ckn.io/blog/2017/11/14/wireguard-vpn-typical-setup/

apt update -y
apt install -y resolvconf wireguard

mkdir -m 0700 -p /etc/wireguard/
cat << EOF > /etc/wireguard/wg0.conf
[Interface]
Address = 10.60.30.1/24
ListenPort = 51820
PrivateKey = UK+LKyjdy/qi6kFKjIRQcU+2o+gFQGL73lIwxl6uQFg=
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o enp0s3 -j MASQUERADE

[Peer]
PublicKey = VO6ENMHgBF73OdFZoiRUVDNG/6GEoMEVRDNEEYkFfRg=
AllowedIPs = 10.60.30.2/32

EOF

ufw allow 51820/udp
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0
systemctl restart wg-quick@wg0

sudo iptables -I INPUT 1 -i enp0s3 -j ACCEPT
sudo iptables -I INPUT 1 -i wg0 -j ACCEPT
sudo iptables -I FORWARD 1 -i eth0 -o wg0 -j ACCEPT
sudo iptables -I FORWARD 1 -i wg0 -o eth0 -j ACCEPT
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1

# Create private keys
wg genkey | tee /tmp/server_private_key | wg pubkey > /tmp/server_public_key

# Create clients keys
for ((i=0;i<$1;i++)); do 
  wg genkey | tee /tmp/client${i}_private_key | wg pubkey > /tmp/client${i}_public_key;
done
