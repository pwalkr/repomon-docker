FROM alpine:3.12

ENTRYPOINT ["/start.sh"]
HEALTHCHECK CMD /healthcheck.sh
ENV GIT_ASKPASS=/usr/local/bin/askpass.sh

RUN apk add --no-cache \
    git \
    git-lfs

COPY start.sh /
COPY healthcheck.sh /healthcheck.sh
COPY askpass.sh /usr/local/bin/askpass.sh
COPY monitor.sh /usr/local/bin/monitor.sh
