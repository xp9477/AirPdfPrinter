#!/bin/sh

# Start CUPS, await readiness, then launch Avahi for AirPrint discovery
cupsd
while ! lpstat -r 2>/dev/null | grep -q "running"; do
  sleep 1
done
avahi-daemon -D
