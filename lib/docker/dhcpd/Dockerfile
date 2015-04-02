# dhcpd
FROM ubuntu:14.04
MAINTAINER topos (slacket@gmail.com)

RUN apt-get update -y 
RUN apt-get upgrade -y

RUN sudo apt-get install isc-dhcp-server
RUN sudo apt-get install isc-dhcp-client

ADD dhcpd.conf /etc/dhcp/
ADD pipework /usr/bin/pipework

USER daemon
ENTRYPOINT ["dhcpd -f"]


