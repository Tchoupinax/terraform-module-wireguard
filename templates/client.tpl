[Interface]
PrivateKey = ${client_private_key}
Address = ${ip_on_the_vpn}
ListenPort = 51820
DNS = 1.1.1.1

[Peer]
PublicKey = ${server_public_key}
Endpoint = ${server_ip}:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 21