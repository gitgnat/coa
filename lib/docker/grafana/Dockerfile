FROM ubuntu:14.10
MAINTAINER ml (metaml@gmail.com)

RUN locale-gen en_US en_US.UTF-8 && dpkg-reconfigure locales && update-locale LC_ALL="en_US.UTF-8"
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y && apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --quiet wget curl ruby software-properties-common
RUN DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:nginx/stable \
    && apt-get update \
    && apt-get install -y nginx \
    && rm -rf /var/lib/apt/lists/* \
    && echo "\ndaemon off;" >> /etc/nginx/nginx.conf \
    && chown -R www-data:www-data /var/lib/nginx
RUN rm -f /etc/nginx/sites-enabled/default
ADD grafana.conf /etc/nginx/sites-enabled/

ADD https://raw.github.com/jpetazzo/pipework/master/pipework /usr/local/bin/pipework
RUN chmod a+x /usr/local/bin/pipework

ADD register /usr/local/bin/register
RUN chmod a+x /usr/local/bin/register

WORKDIR /opt
ADD http://grafanarel.s3.amazonaws.com/grafana-1.9.1.tar.gz /opt/grafana-1.9.1.tar.gz
RUN tar xf grafana-1.9.1.tar.gz && rm -f grafana-1.9.1.tar.gz && mv -f grafana-1.9.1 grafana

ADD config.js /opt/grafana/config.js
RUN chmod a-xw,a+r /opt/grafana/config.js

ADD htpasswd /opt/grafana/.htpasswd
RUN chmod a-xw,a+r /opt/grafana/.htpasswd

ADD start /opt/grafana/start
RUN chmod a+x /opt/grafana/start

WORKDIR /opt/grafana
ENTRYPOINT ["/opt/grafana/start"]
