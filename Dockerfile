FROM teddysun/xray:latest

RUN apk add --no-cache openssl

# Generate self-signed certificate - replace YOUR_SUBDOMAIN with your DuckDNS subdomain
RUN mkdir -p /etc/ssl/certs/xray && \
    openssl req -x509 -nodes -newkey rsa:2048 \
      -keyout /etc/ssl/certs/xray/privkey.pem \
      -out /etc/ssl/certs/xray/fullchain.pem \
      -days 365 \
      -subj "/CN=YOUR_SUBDOMAIN.duckdns.org" \
      -addext "subjectAltName=DNS:YOUR_SUBDOMAIN.duckdns.org"

EXPOSE 8443

CMD ["xray", "-c", "/etc/xray/config.json"]
