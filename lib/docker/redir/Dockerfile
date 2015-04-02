# redir
FROM ubuntu:14.04
MAINTAINER topos (slacket@gmail.com)

RUN apt update -y 
RUN apt upgrade -y
RUN apt install -y libgmp10

ADD redir /
RUN chmod +x /redir

ADD redir.yml /etc/
RUN chmod a-w /etc/redir.yml

USER daemon
EXPOSE 8080
ENTRYPOINT ["/redir"]
