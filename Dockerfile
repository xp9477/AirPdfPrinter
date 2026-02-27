# ====================================================================== #
# APP - Air PDF Printer
# Virtual PDF AirPrint Printer Docker Image
# ====================================================================== #

# Base image
# ---------------------------------------------------------------------- #
FROM alpine:3.23

# Author
# ---------------------------------------------------------------------- #
LABEL maintainer="thyrlian@gmail.com"

# Listen on ports
EXPOSE 631
EXPOSE 5353/UDP

# Install CUPS and CUPS-PDF packages
# - cups-filters: provides pdftops and pdftoraster backends
# - cups-pdf: virtual PDF printer driver (from edge/testing repository)
RUN apk add --no-cache \
        cups \
        cups-filters \
    && apk add --no-cache \
        --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing \
        cups-pdf

# Configure the CUPS scheduler
ARG ADMIN_PASSWORD=printer
RUN mv /etc/cups/cupsd.conf /etc/cups/cupsd.conf.bak && \
    chmod a-w /etc/cups/cupsd.conf.bak && \
    addgroup root lpadmin && \
    echo -e "${ADMIN_PASSWORD}\n${ADMIN_PASSWORD}" | passwd root
ADD conf/cupsd.conf /etc/cups/

# Setup PDF printer
ADD --chmod=0755 scripts/config.sh /tmp/
RUN /tmp/config.sh

# Configure AirPrint
ADD conf/AirPrint-PDF.service /etc/avahi/services/

# Advertise AirPrint via Bonjour broadcast
RUN apk add --no-cache avahi && \
    echo "image/urf urf (0,UNIRAST)" > /usr/share/cups/mime/apple.types && \
    echo "image/urf urf (0,UNIRAST)" > /usr/share/cups/mime/local.types && \
    echo "image/urf application/vnd.cups-postscript 66 pdftops" > /usr/share/cups/mime/local.convs && \
    echo "image/urf urf string(0,UNIRAST<00>)" > /usr/share/cups/mime/airprint.types && \
    echo "image/urf application/pdf 100 pdftoraster" > /usr/share/cups/mime/airprint.convs && \
    sed -i "s/.*enable-dbus=.*/enable-dbus=no/g" /etc/avahi/avahi-daemon.conf

ADD --chmod=0755 scripts/start.sh /usr/local/bin/
ADD --chmod=0755 scripts/stop.sh /usr/local/bin/
CMD ["sh", "-c", "start.sh && tail -f /dev/null"]
