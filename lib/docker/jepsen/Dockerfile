FROM ubuntu:14.10
MAINTAINER ml (metaml@gmail.com)

RUN locale-gen en_US en_US.UTF-8
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales 
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:webupd8team/java
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y 

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y aptitude \
                                                      curl \
                                                      git \
                                                      libssl-dev \
                                                      make \
                                                      ruby2.1 \
                                                      unzip \
                                                      wget 

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java8-installer

ADD http://central.maven.org/maven2/org/clojure/clojure/1.6.0/clojure-1.6.0.jar /usr/local/lib/clojure1.6/
RUN cd /usr/local/lib && ln -s clojure1.6 clojure
ADD https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein /usr/local/bin/lein
RUN chmod a+rx /usr/local/bin/lein

# @todo: should probably not be here
RUN cp /dev/null /etc/hostname && echo jepsen-dev > /etc/hostname

WORKDIR /
ENTRYPOINT ["/bin/bash"]
