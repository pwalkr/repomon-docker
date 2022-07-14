FROM alpine:3.12

RUN apk add --no-cache \
    bash \
    git \
    git-lfs \
    openssh-client

COPY start.sh /
COPY monitor.sh /usr/local/bin/monitor.sh
COPY healthcheck.sh /usr/local/bin/healthcheck.sh

HEALTHCHECK CMD /usr/local/bin/healthcheck.sh

ENTRYPOINT ["/start.sh"]
