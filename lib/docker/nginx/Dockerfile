FROM ubuntu:14.10
MAINTAINER metaml (metaml@gmail.com)

RUN locale-gen en_US en_US.UTF-8
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales 
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common ruby2.1
RUN DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:nginx/stable \
    && apt-get update \
    && apt-get install -y nginx \
    && rm -rf /var/lib/apt/lists/* \
    && echo "\ndaemon off;" >> /etc/nginx/nginx.conf \
    && chown -R www-data:www-data /var/lib/nginx

RUN rm -f /etc/nginx/sites-enabled/default
ADD edu.conf /etc/nginx/sites-enabled/

VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx/analytics"]

ADD https://raw.github.com/jpetazzo/pipework/master/pipework /usr/local/bin/pipework
RUN chmod a+x /usr/local/bin/pipework

ADD register /usr/local/bin/register
RUN chmod a+x /usr/local/bin/register

ADD start /opt/nginx/start
RUN chmod a+x /opt/nginx/start

WORKDIR /etc/nginx
ENTRYPOINT ["/opt/nginx/start"]
