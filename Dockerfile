# ====================================================================== #
# APP - Air PDF Printer
# Virtual PDF AirPrint Printer Docker Image
# ====================================================================== #

# Base image
# ---------------------------------------------------------------------- #
FROM ubuntu:jammy

# Author
# ---------------------------------------------------------------------- #
LABEL maintainer "thyrlian@gmail.com"

# listen on ports
EXPOSE 631
EXPOSE 5353/UDP

# install and configure packages
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    cups \
    printer-driver-cups-pdf \
    avahi-daemon \
    libnss-mdns && \
    # configure CUPS
    mv /etc/cups/cupsd.conf /etc/cups/cupsd.conf.bak && \
    chmod a-w /etc/cups/cupsd.conf.bak && \
    usermod -aG lpadmin root && \
    # configure AirPrint
    echo "image/urf urf (0,UNIRAST)" > /usr/share/cups/mime/apple.types && \
    sed -i "s/.*enable-dbus=.*/enable-dbus=no/g" /etc/avahi/avahi-daemon.conf && \
    # cleanup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# configure the CUPS scheduler
ARG ADMIN_PASSWORD=printer
RUN echo "root:${ADMIN_PASSWORD}" | chpasswd
ADD cupsd.conf /etc/cups/

# setup PDF printer
ADD --chmod=0755 config.sh /tmp/
RUN /tmp/config.sh

# configure AirPrint
ADD AirPrint-PDF.service /etc/avahi/services/

# create a volume for receiving PDF files
VOLUME ["/root/PDF"]

# launch CUPS print server
CMD service cups start && service avahi-daemon start && tail -f /dev/null
