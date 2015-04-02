FROM ubuntu:14.04.1
MAINTAINER metaml (metaml@gmail.com)

RUN DEBIAN_FRONTEND=noninteractive locale-gen en_US en_US.UTF-8
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales 
RUN DEBIAN_FRONTEND=noninteractive update-locale LC_ALL="en_US.UTF-8"

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y 
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential libgmp-dev

RUN mkdir -p /edu
ADD start /edu/start
RUN chmod +x /edu/start
ADD register /edu/register
RUN chmod +x /edu/register

USER daemon
EXPOSE 8080
ENTRYPOINT ["/edu/start"]
