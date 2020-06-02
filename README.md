# Redirect
A Dockerized iptables instance to redirect network traffic to a new IP.

## Features
- TCP/UDP support
- Multiple ports & port range support

## Usage
*Requirenment tips*: For interacting with the network stack, you **should** use `--cap-add=NET_ADMIN` to modify the iptables.

**Example**: 
  
  For incoming **TCP:80** and **UDP:1234-1236** redirect to **DESTINATION_IP:1.1.1.1**.

### Docker command line
#### Foreground mode
```shell
$ docker run --name=ip-redirect -it --rm --cap-add=NET_ADMIN \
    -p 80:80/tcp -p 1234-1236:1234-1236/udp \
    -e "TCP_PORTS=80" -e "UDP_PORTS=1234-1236" -e "DESTINATION_IP=1.1.1.1" \
    smallblack/redirect-latest
```

#### Detached mode
```shell
$ docker run --name=ip-redirect -d --rm --cap-add=NET_ADMIN \
    -p 80:80/tcp -p 1234-1236:1234-1236/udp \
    -e "TCP_PORTS=80" -e "UDP_PORTS=1234-1236" -e "DESTINATION_IP=1.1.1.1" \
    smallblack/redirect-latest
```

### Docker-compose
```yaml
version: '3'
services:
  iptables:
    image: smallblack/redirect-latest
    container_name: ip-redirect
    cap-add: 
      - NET_ADMIN
    ports:
      - "80:80/tcp"
      - "1234-1236:1234-1236/udp"
    environment:
      - TCP_PORTS=80
      - UDP_PORTS=1234-1236
      - DESTINATION_IP=1.1.1.1
```

```shell
$ docker-compose up -d
```

## Parameters
- `-p 8443:443/tcp` Forwards port 443 from the host to the container.

- `-e "KEY=value"` These are environment variables which configure the container. See below for a description of their meanings.

### Environment variables
- **DESTINATION_IP** (Required) Set the destination IP (IPv4 only) for the server you redirecting to.
- **TCP_PORTS** (Optional) Support multiple ports and port range. For enumerated ports, you should separate with `,`. For port range, both of `:` or `-` is working. e.g. `80,443,1234:1236` or `80,443,1234-1236`.
- **UDP_PORTS** (Optional) Same rules with **TCP_PORTS**.

## Feature TO-DO
- IPv6 support: consider to create a new image or add ip6tables.