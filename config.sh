#!/bin/bash

PTR="Canon_PIXMA_TS3380"

service cups start

echo "Configuring the printer $PTR."
lpadmin -p $PTR -v cups-pdf:/ -E -P /usr/share/ppd/cups-pdf/CUPS-PDF_opt.ppd

echo "Setting the default printer to $PTR."
lpadmin -d $PTR

service cups stop
