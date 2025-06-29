FROM docker:dind

RUN apk add --no-cache \
    tar \
    zstd \
    dcron

COPY backup.sh /backup.sh
RUN chmod +x /backup.sh

RUN echo "55 2 * * * /backup.sh >> /proc/1/fd/1 2>> /proc/1/fd/2" > /etc/crontabs/root

ENTRYPOINT ["crond", "-f", "-d", "2"]
