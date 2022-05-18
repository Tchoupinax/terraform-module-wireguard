[Interface]
PrivateKey = ${server_private_key}
Address = ${ip_on_the_vpn}
ListenPort = 51820

%{ for peer in jsondecode(peers) ~}
[Peer]
PublicKey = ${peer.public_key}
AllowedIPs = ${peer.ip_on_the_vpn}

%{ endfor ~}
