FROM ubuntu:14.10
MAINTAINER ml (metaml@gmail.com)

RUN DEBIAN_FRONTEND=noninteractive locale-gen en_US en_US.UTF-8
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales 
RUN DEBIAN_FRONTEND=noninteractive update-locale LC_ALL="en_US.UTF-8"
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y && apt-get install -y --quiet unzip wget ruby make gcc

ADD https://raw.github.com/jpetazzo/pipework/master/pipework /usr/local/bin/pipework
ADD register /usr/local/bin/register
ADD start /opt/redis/start
RUN chmod a+x /usr/local/bin/pipework /usr/local/bin/register /opt/redis/start

RUN cd /tmp \
    && wget http://download.redis.io/redis-stable.tar.gz \
    && tar xvzf redis-stable.tar.gz \
    && cd redis-stable \
    && make \
    && make install \
    && cp -f src/redis-sentinel /usr/local/bin \
    && mkdir -p /etc/redis \
    && cp -f *.conf /etc/redis \
    && rm -rf /tmp/redis-stable* \
    && sed -i 's/^\(bind .*\)$/# \1/' /etc/redis/redis.conf \
    && sed -i 's/^\(daemonize .*\)$/# \1/' /etc/redis/redis.conf \
    && sed -i 's/^\(dir .*\)$/# \1\ndir \/data/' /etc/redis/redis.conf \
    && sed -i 's/^\(logfile .*\)$/# \1/' /etc/redis/redis.conf

WORKDIR /etc/redis
ENTRYPOINT ["/opt/redis/start"]
