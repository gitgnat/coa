FROM ubuntu:14.10
MAINTAINER ml (metaml@gmail.com)

RUN locale-gen en_US en_US.UTF-8 && dpkg-reconfigure locales && update-locale LC_ALL="en_US.UTF-8"
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y && apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --quiet wget curl ruby software-properties-common

ADD https://raw.github.com/jpetazzo/pipework/master/pipework /usr/local/bin/pipework
RUN chmod a+x /usr/local/bin/pipework

ADD register /usr/local/bin/register
RUN chmod a+x /usr/local/bin/register

RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update -y 
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java8-installer

WORKDIR /opt
ADD https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.2.tar.gz /opt/
RUN tar xf elasticsearch-1.4.2.tar.gz && rm -f elasticsearch-1.4.2.tar.gz
RUN mv -f elasticsearch-1.4.2 es

RUN mv -f /opt/es/config/elasticsearch.yml /opt/es/config/elasticsearch.yml-
ADD elasticsearch.yml /opt/es/config/elasticsearch.yml

ADD start /opt/es/start
RUN chmod a+x /opt/es/start

VOLUME ["/data"]
WORKDIR /data
ENTRYPOINT ["/opt/es/start"]
