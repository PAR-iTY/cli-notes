docker run -d \
  --name=wg-easy \
  -e WG_HOST=192.168.1.118 \
  -e PASSWORD=admin \
  -v ~/.wg-easy:/etc/wireguard \
  -p 51820:51820/udp \
  -p 51821:51821/tcp \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --sysctl="net.ipv4.ip_forward=1" \
  --restart unless-stopped \
  weejewel/wg-easy

docker run -d --name=wg-easy -e WG_HOST=192.168.1.1 -e PASSWORD=admin -v ~/.wg-easy:/etc/wireguard -p 51820:51820/udp -p 51821:51821/tcp --cap-add=NET_ADMIN --cap-add=SYS_MODULE --sysctl="net.ipv4.conf.all.src_valid_mark=1" --sysctl="net.ipv4.ip_forward=1" --restart unless-stopped weejewel/wg-easy

// quick and dirty
winget install --id Cloudflare.cloudflared

cloudflared tunnel --url 192.168.1.118:8096

// ----------------------------------------------------

DDNS = `ipconfig/all` DHCP Server value
     = 192.168.1.1
// to confirm:
`nslookup 192.168.1.1`

// peer endpoint (in server and/or client config?)
Endpoint = <IPADDRESS YOU CONFIGURED>:<PORT YOU CONFIGURED>
         = <DDNS>:<FORWARDED-PORT?>
         = 192.168.1.1:<???>