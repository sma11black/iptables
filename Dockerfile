FROM alpine:latest
LABEL version="1.0"
LABEL description="A Dockerized iptables instance \
to redirect network traffic to a new IP."
LABEL maintainer="smallblack@outlook.com"

COPY entrypoint.sh /entrypoint.sh

# Install iptables
RUN apk add --upgrade --no-cache iptables && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]