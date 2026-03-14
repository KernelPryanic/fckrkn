FROM teddysun/xray:latest

RUN apk add --no-cache openssl

# Generate self-signed certificate - replace YOUR_SUBDOMAIN with your DuckDNS subdomain
RUN mkdir -p /etc/ssl/certs/xray && \
    openssl req -x509 -nodes -newkey rsa:2048 \
      -keyout /etc/ssl/certs/xray/privkey.pem \
      -out /etc/ssl/certs/xray/fullchain.pem \
      -days 3650 \
      -subj "/CN=disk.yandex.ru" \
      -addext "subjectAltName=DNS:disk.yandex.ru,DNS:yandex.ru"

EXPOSE 8443 51820/udp 8080 8880 2096

CMD ["xray", "-c", "/etc/xray/config.json"]
