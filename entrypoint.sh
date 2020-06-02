#!/bin/sh
DEST_IP=${DESTINATION_IP:-127.0.0.1}

# check for privileged access
iptables -t nat -L -n -v --line-numbers
if ! [ $? -eq 0 ]; then
  echo "Sorry, '--cap-add=NET_ADMIN' flag is required to be set for using iptables"; exit 1;
fi

# iptables prerouting
if [ -z "$TCP_PORTS" -a -z "$UDP_PORTS" ]; then
  iptables -t nat -A PREROUTING -i eth0 -j DNAT --to-destination ${DEST_IP}
else
  if expr "$TCP_PORTS" : "[0-9, :-]\+$"  >/dev/null; then
    TCP_PORTS="$TCP_PORTS" IFS=", "
    for TCP_PORT in $TCP_PORTS; do
      if expr "$TCP_PORT" : "[0-9]\+[:-][0-9]\+$" >/dev/null; then
        PORT_BEGIN=$(echo $TCP_PORT | awk -F'[:-]' '{print $1}')
        PORT_END=$(echo $TCP_PORT | awk -F'[:-]' '{print $2}')
        iptables -t nat -A PREROUTING -p tcp --dport ${PORT_BEGIN}:${PORT_END} -j DNAT --to-destination  ${DEST_IP}:${PORT_BEGIN}-${PORT_END}
      else
        iptables -t nat -A PREROUTING -p tcp --dport ${TCP_PORT} -j DNAT --to-destination  ${DEST_IP}:${TCP_PORT}
      fi
    done
  fi

  if expr "$UDP_PORTS" : "[0-9, :-]\+$"  >/dev/null; then
    UDP_PORTS="$UDP_PORTS" IFS=", "
    for UDP_PORT in $UDP_PORTS; do
      if expr "$UDP_PORT" : "[0-9]\+[:-][0-9]\+$" >/dev/null; then
        PORT_BEGIN=$(echo $UDP_PORT | awk -F'[:-]' '{print $1}')
        PORT_END=$(echo $UDP_PORT | awk -F'[:-]' '{print $2}')
        iptables -t nat -A PREROUTING -p udp --dport ${PORT_BEGIN}:${PORT_END} -j DNAT --to-destination  ${DEST_IP}:${PORT_BEGIN}-${PORT_END}
      else
        iptables -t nat -A PREROUTING -p udp --dport ${UDP_PORT} -j DNAT --to-destination  ${DEST_IP}:${UDP_PORT}
      fi
    done
  fi
fi

# iptables masquerade
iptables -t nat -A POSTROUTING -j MASQUERADE
# SOURCE=$(ip a | grep eth0 | grep inet | awk '{print $2}')
# iptables -t nat -A POSTROUTING -s $SOURCE -j MASQUERADE

# Ah, ha, ha, ha, stayin' alive...
while :; do :; done & kill -STOP $! && wait $!