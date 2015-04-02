# mesos
FROM ubuntu:14.04
MAINTAINER topos (slacket@gmail.com)

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
RUN apt-get update -y 
RUN apt-get upgrade -y
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update -y 

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java8-installer
RUN apt-get install -y oracle-java8-set-default
RUN apt-get install -y python-setuptools python-protobuf curl

RUN locale-gen en_US en_US.UTF-8
RUN dpkg-reconfigure locales 
RUN update-locale LC_ALL="en_US.UTF-8"

RUN curl -sSfL http://downloads.mesosphere.io/master/ubuntu/14.04/mesos_0.19.0~ubuntu14.04%2B1_amd64.deb --output /mesos.deb
RUN dpkg -i /mesos.deb
RUN rm -f /mesos.deb

RUN curl -sSfL http://downloads.mesosphere.io/master/ubuntu/14.04/mesos-0.19.0_rc2-py2.7-linux-x86_64.egg --output /mesos.egg
RUN easy_install /mesos.egg
RUN rm -f /mesos.egg

RUN echo zk://172.17.42.1:2181/mesos > /etc/mesos/zk

USER root
EXPOSE 5050
ENTRYPOINT ["/usr/bin/mesos-init-wrapper","master"]
