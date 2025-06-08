#!/bin/bash

PTR="Brother-MFC-L2710DW"

service cups start

echo "Configuring the printer $PTR."
lpadmin -p $PTR -v cups-pdf:/ -E -P /usr/share/ppd/cups-pdf/CUPS-PDF_opt.ppd -o printer-is-shared=true -o printer-info="Brother MFC-L2710DW" -o printer-location="Home Office" -o printer-make-and-model="Brother MFC-L2710DW" -o printer-state=3 -o printer-state-reasons=none -o printer-state-message="Ready to print"

echo "Setting the default printer to $PTR."
lpadmin -d $PTR

service cups stop
