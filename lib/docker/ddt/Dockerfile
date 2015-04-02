# stolen from https://github.com/jpetazzo/pxe/blob/master/Dockerfile
FROM ubuntu:14.10
MAINTAINER gitgnat@gmail.com

RUN DEBIAN_FRONTEND=noninteractive locale-gen en_US en_US.UTF-8
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales 
RUN DEBIAN_FRONTEND=noninteractive update-locale LC_ALL="en_US.UTF-8"

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y && apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --quiet dnsmasq wget curl ruby

ADD https://raw.github.com/jpetazzo/pipework/master/pipework /usr/local/bin/pipework
RUN chmod +x /usr/local/bin/pipework

ADD register /usr/local/bin/register
RUN chmod +x /usr/local/bin/register

WORKDIR /tftp
ENV ARCH amd64
ENV DIST trusty
ENV MIRROR http://archive.ubuntu.com
RUN wget $MIRROR/ubuntu/dists/$DIST/main/installer-$ARCH/current/images/netboot/ubuntu-installer/$ARCH/linux
RUN wget $MIRROR/ubuntu/dists/$DIST/main/installer-$ARCH/current/images/netboot/ubuntu-installer/$ARCH/initrd.gz
RUN wget $MIRROR/ubuntu/dists/$DIST/main/installer-$ARCH/current/images/netboot/ubuntu-installer/$ARCH/pxelinux.0
RUN mkdir pxelinux.cfg
RUN printf "DEFAULT linux\nKERNEL linux\nAPPEND initrd=initrd.gz\n" > pxelinux.cfg/default

ADD start /opt/ddt/start
RUN chmod +x /opt/ddt/start

RUN mkdir -p /var/lib/misc && chown daemon /var/lib/misc

WORKDIR /opt/ddt
USER root
ENTRYPOINT ["/opt/ddt/start"]
