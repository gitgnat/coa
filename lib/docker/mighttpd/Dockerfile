# mighttpd
FROM ubuntu:14.04
MAINTAINER topos (slacket@gmail.com)

RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" \
    >> /etc/apt/sources.list
RUN apt-get update -y 
RUN apt-get upgrade -y
RUN apt-get build-dep -y build-essential
RUN apt-get install -y mighttpd2

RUN cd / && /usr/lib/mighttpd2/mkindex 

WORKDIR /var/tmp/mighttpd
COPY eg.conf /etc/eg.conf
COPY eg.route /etc/eg.route

ENTRYPOINT ["/usr/bin/mighty","/etc/eg.conf","/etc/eg.route"]

USER daemon
EXPOSE 8080
