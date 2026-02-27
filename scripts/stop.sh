#!/bin/sh

# Stop Avahi and CUPS daemons
avahi-daemon --kill 2>/dev/null
kill -TERM $(cat /var/run/cups/cupsd.pid 2>/dev/null) 2>/dev/null || killall cupsd
