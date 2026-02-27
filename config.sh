#!/bin/sh

PTR="PDF"

# Ensure cups-pdf backend runs with root privileges
chmod 0700 /usr/lib/cups/backend/cups-pdf

# Create spool directories for cups-pdf
CUPS_PDF_SPOOL="/var/spool/cups-pdf/SPOOL"
mkdir -p "$CUPS_PDF_SPOOL"
chmod 1777 "$CUPS_PDF_SPOOL"

# Start CUPS daemon and wait until ready
cupsd
echo "Waiting for CUPS to start..."
while ! lpstat -r 2>/dev/null | grep -q "running"; do
  sleep 1
done

echo "Configuring the printer $PTR."
lpadmin -p $PTR -v cups-pdf:/ -E -P /usr/share/ppd/cups-pdf/cups-pdf.ppd

echo "Setting the default printer to $PTR."
lpadmin -d $PTR

# Wait for CUPS to flush printer configuration to disk
while [ ! -s /etc/cups/printers.conf ]; do
  sleep 1
done
kill -TERM $(cat /var/run/cups/cupsd.pid 2>/dev/null) 2>/dev/null || killall cupsd
