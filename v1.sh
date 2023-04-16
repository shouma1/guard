#!/bin/bash

VPS1_PRIVATE_IP="0.0.0.0"
VPS2_PUBLIC_IP="0.0.0.0"
VPS2_PRIVATE_IP="0.0.0.0"

VPS1_WG_PORT="12345"
VPS2_WG_PORT="23456"

VPS1_PRIVATE_KEY="4Mmn4hsaYPXRraOO8tCVofgm6e2CiUa0pS7gQDgFY0Q="
VPS1_PUBLIC_KEY="dB32qChH3lrYoSc8pinvfBCXoI19Q71BIxEA1HX8JVM="
VPS2_PUBLIC_KEY="UQ1/s+F3XeKqgpuAJ6ueQAkaqAUy0WHREgLdfzi8q3g="

apt-get update
apt-get install -y wireguard iptables
echo -e "[Interface]\nAddress = $VPS1_PRIVATE_IP/24\nPrivateKey = $VPS1_PRIVATE_KEY\nListenPort = $VPS1_WG_PORT\n\n[Peer]\nPublicKey = $VPS2_PUBLIC_KEY\nAllowedIPs = $VPS2_PRIVATE_IP/32\nEndpoint = $VPS2_PUBLIC_IP:$VPS2_WG_PORT" > /etc/wireguard/wg0.conf
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0
iptables -t nat -A PREROUTING -p udp --dport $VPS1_WG_PORT -j DNAT --to-destination $VPS2_PRIVATE_IP:$VPS2_WG_PORT
iptables -t nat -A POSTROUTING -p udp -d $VPS2_PRIVATE_IP --dport $VPS2_WG_PORT -j SNAT --to-source $VPS1_PRIVATE_IP
