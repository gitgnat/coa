FROM ubuntu:14.10
MAINTAINER ml (metaml@gmail.com)

RUN DEBIAN_FRONTEND=noninteractive locale-gen en_US en_US.UTF-8
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales 
RUN DEBIAN_FRONTEND=noninteractive update-locale LC_ALL="en_US.UTF-8"

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y && apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --quiet unzip curl ruby

ADD https://raw.github.com/jpetazzo/pipework/master/pipework /usr/local/bin/pipework
RUN chmod a+x /usr/local/bin/pipework

ADD register /usr/local/bin/register
RUN chmod a+x /usr/local/bin/register

RUN mkdir -p /opt/consul/bin
ADD https://dl.bintray.com/mitchellh/consul/0.5.0_linux_amd64.zip /tmp/consul.zip
RUN unzip /tmp/consul.zip -d /opt/consul/bin/ && chmod +x /opt/consul/bin/*
ADD https://dl.bintray.com/mitchellh/consul/0.5.0_web_ui.zip /tmp/webui.zip
RUN unzip /tmp/webui.zip -d /opt/consul && mv -f /opt/consul/dist /opt/consul/webui
RUN rm -rf /opt/consul/tmp

ADD start /opt/consul/start
RUN chmod a+x /opt/consul/start

# consul service ports:
# - server rpc: 8300
# - serf lan: 8301
# - serf wan: 8302
# - client rpc: 8400
# - http api: 8500 (wui)
# - dns: 8600
#EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

WORKDIR /opt/consul
USER root
ENTRYPOINT ["/opt/consul/start"]
