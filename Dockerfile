FROM phusion/baseimage:0.9.17
MAINTAINER Kevin Mook <kevin@kevinmook.com>

# copied from https://hub.docker.com/r/phantium/ark/~/dockerfile/
RUN apt-get update \
    && apt-get -y install lib32gcc1 wget \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# RUN mkdir -p /data/ark/backup \
#     && useradd -d /data/ark -s /bin/bash --uid 1000 ark \
#     && chown -R ark: /data/ark

RUN cd /tmp \
    && mkdir /steamcmd \
    && wget -q https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    && tar -xzf steamcmd_linux.tar.gz -C /steamcmd

# add this machine's public key so we can ssh into the container
ADD generated/id_rsa.pub /tmp/id_rsa.pub
RUN \
    cat /tmp/id_rsa.pub >>/root/.ssh/authorized_keys && \
    rm -f /tmp/id_rsa.pub

# ADD /container_scripts/ark /ark/
ADD /container_scripts/init.d/* /etc/my_init.d/

# fix ark specific issues:
RUN echo "fs.file-max=100000" >>/etc/sysctl.conf \
    && echo "*               soft    nofile          1000000" >>/etc/security/limits.conf \
    && echo "*               hard    nofile          1000000" >>/etc/security/limits.conf \
    && echo "session required pam_limits.so" >>/etc/pam.d/common-session


# ADD container_scripts/duplicity-backup/duplicity-backup.sh /usr/bin/
# ADD configs/duplicity/duplicity-backup.conf.example /etc/duplicity-backup.conf.example
# RUN echo "*/30 * * * *   root    /minecraft/minecraft backup" >>/etc/crontab

# allow sshing into the container
RUN rm -f /etc/service/sshd/down

COPY /container_scripts/services/ark/run /etc/service/ark/run

# Forward apporpriate ports
EXPOSE 27015/tcp 27015/udp 7777/tcp 7777/udp

VOLUME ["/data"]

CMD ["/sbin/my_init"]
