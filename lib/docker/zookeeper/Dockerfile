# zookeeper
FROM ubuntu:14.04
MAINTAINER topos (slacket@gmail.com)

RUN echo deb http://archive.ubuntu.com/ubuntu trusty main universe >>/etc/apt/sources.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
RUN apt-get update -y 
RUN apt-get upgrade -y
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update -y 

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java8-installer
RUN apt-get install oracle-java8-set-default
RUN apt-get install -y python-setuptools python-software-properties curl wget
RUN apt-get install -y coreutils
RUN apt-get install -y zookeeperd

RUN mkdir -p /var/zookeeper
RUN chown -R zookeeper /var/zookeeper

USER zookeeper

ADD zoo.cfg /etc/zookeeper/conf/
ADD myid /etc/zookeeper/conf/

EXPOSE 2181 2888 38888

ENTRYPOINT ["/usr/share/zookeeper/bin/zkServer.sh","start-foreground"]
