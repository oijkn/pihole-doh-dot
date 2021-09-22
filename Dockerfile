ARG FRM='pihole/pihole'
ARG TAG='latest'

FROM ${FRM}:${TAG}
ARG FRM
ARG TAG

LABEL maintainer="oijkn"
LABEL description="Official pihole docker with both DoH (DNS over HTTPS) and DoT (DNS over TLS) clients"

COPY config /config
COPY ./install.sh /

RUN /bin/bash /install.sh \
    && rm -f /install.sh

RUN echo "$(date "+%d.%m.%Y %T") - Built from ${FRM}:${TAG} by Oijkn." >> /build_date.info
