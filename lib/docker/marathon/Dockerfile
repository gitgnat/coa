# mesos
FROM ubuntu:14.04
MAINTAINER topos (slacket@gmail.com)

RUN echo deb http://archive.ubuntu.com/ubuntu trusty main universe >>/etc/apt/sources.list
RUN echo deb http://get.docker.io/ubuntu docker main >/etc/apt/sources.list.d/docker.list
RUN echo deb http://repos.mesosphere.io/ubuntu/ trusty main >/etc/apt/sources.list.d/mesosphere.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
RUN apt-get update -y 
RUN apt-get upgrade -y

RUN apt-get build-dep -y build-essential
RUN apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update -y 

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java8-installer
RUN apt-get install -y python-setuptools python-software-properties curl

RUN apt-get install -y lxc-docker
RUN apt-get install -y mesos

ADD http://downloads.mesosphere.io/marathon/marathon-0.6.0/marathon-0.6.0.tgz /tmp/marathon.tgz
RUN mkdir -p /opt/marathon && tar xzf /tmp/marathon.tgz -C /opt/marathon --strip=1 && rm -f /tmp/marathon.tgz

USER daemon
EXPOSE 8080

WORKDIR /opt/marathon
ENTRYPOINT ["/opt/marathon/bin/start"]
