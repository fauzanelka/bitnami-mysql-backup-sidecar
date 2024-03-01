FROM debian:11-slim

LABEL org.opencontainers.image.source https://github.com/fauzanelka/bitnami-mysql-backup-sidecar

COPY --from=bitnami/mysql:8.0-debian-11 /opt/bitnami/mysql/bin/mysql /opt/bitnami/mysql/bin/mysql
COPY --from=bitnami/mysql:8.0-debian-11 /opt/bitnami/mysql/bin/mysqladmin /opt/bitnami/mysql/bin/mysqladmin
COPY --from=bitnami/mysql:8.0-debian-11 /opt/bitnami/mysql/bin/mysqlcheck /opt/bitnami/mysql/bin/mysqlcheck
COPY --from=bitnami/mysql:8.0-debian-11 /opt/bitnami/mysql/bin/mysqldump /opt/bitnami/mysql/bin/mysqldump
COPY --from=bitnami/mysql:8.0-debian-11 /opt/bitnami/mysql/bin/mysqlimport /opt/bitnami/mysql/bin/mysqlimport
COPY --from=bitnami/mysql:8.0-debian-11 /opt/bitnami/mysql/bin/mysqlpump /opt/bitnami/mysql/bin/mysqlpump
COPY --from=bitnami/mysql:8.0-debian-11 /opt/bitnami/mysql/bin/mysqlslap /opt/bitnami/mysql/bin/mysqlslap

ENV PATH="$PATH:/opt/bitnami/mysql/bin"

ADD https://github.com/rclone/rclone/releases/download/v1.65.2/rclone-v1.65.2-linux-amd64.deb /tmp/rclone-v1.65.2-linux-amd64.deb

RUN apt-get update && apt-get install -y \
    cron \
    vim \
    && dpkg -i /tmp/rclone-v1.65.2-linux-amd64.deb \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

COPY --chmod=755 --chown=root:root scripts/ /root/scripts/
COPY --chmod=600 --chown=root:crontab crontab/ /var/spool/cron/crontabs/

ENTRYPOINT [ "/usr/sbin/cron", "-f" ]