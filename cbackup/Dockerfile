FROM debian:stretch
# Ц цитирование
# https://github.com/alehaa/docker-debian-systemd/blob/master/Dockerfile

RUN echo 'debconf debconf/frontend select teletype' | debconf-set-selections

RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends \
        systemd      \
        systemd-sysv \
        cron         \
        anacron

RUN apt-get clean
RUN rm -rf                        \
    /var/lib/apt/lists/*          \
    /var/log/alternatives.log     \
    /var/log/apt/history.log      \
    /var/log/apt/term.log         \
    /var/log/dpkg.log


RUN systemctl mask --   \
    dev-hugepages.mount \
    sys-fs-fuse-connections.mount

RUN rm -f           \
    /etc/machine-id \
    /var/lib/dbus/machine-id

FROM debian:stretch
COPY --from=0 / /
ENV container docker
STOPSIGNAL SIGRTMIN+3
VOLUME [ "/sys/fs/cgroup", "/run", "/run/lock", "/tmp" ]

CMD [ "/sbin/init" ]

# Закончилось цитирование
# https://github.com/alehaa/docker-debian-systemd/blob/master/Dockerfile
#
# Далее идет установка cbackup и необходимых пакетов.
# Репозиторий alehaa/docker-debian-systemd (https://github.com/alehaa/docker-debian-systemd)
# устанавливаем cbackup и зависимости
RUN cd /tmp/ \
 # install
  && apt-get update -qqy \
  && apt-get -y install \
    git snmp default-jre wget openssh-server \
    php-gmp php-zip php-intl php-ssh2 php-snmp php-mbstring php-mcrypt php-bcmath php-cli php-curl \
    git apache2 php mysql-server php-mysql sudo rsyslog \
  && groupadd -r cbackup \
  && useradd -r -g cbackup -G www-data -d /opt/cbackup -s /bin/bash -c "cBackup System User" cbackup \
  && wget -q -O /tmp/cbackup.deb "http://cbackup.me/latest?package=deb" \
  && dpkg -i /tmp/cbackup.deb \
  && cd / \
  && mv /opt/cbackup /opt/cbackup.orig \
  && mkdir /opt/cbackup \
  && chown www-data:www-data /opt/cbackup \
  && rm -rf /opt/tmp/* \
### Окончательные настройки
#RUN cd /tmp/ \
# обеспечиваем старт cbackup
  && systemctl enable cbackup \
  && echo 'ServerName localhost' >> /etc/apache2/apache2.conf

COPY init.sh /opt
