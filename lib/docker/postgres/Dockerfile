FROM ubuntu:14.10
MAINTAINER M. Lee "metaml@gmail.com"

RUN locale-gen en_US en_US.UTF-8
RUN dpkg-reconfigure locales 
RUN update-locale LC_ALL="en_US.UTF-8"

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y 
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --quiet unzip curl sudo ruby
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --quiet postgresql-9.4 \
                                                              postgresql-contrib-9.4 \
                                                              postgresql-9.4-postgis-2.1 \
                                                              libpq-dev

ADD https://raw.github.com/jpetazzo/pipework/master/pipework /usr/local/bin/pipework
RUN chmod a+x /usr/local/bin/pipework

ADD register /usr/local/bin/register
RUN chmod a+x /usr/local/bin/register

RUN mkdir /etc/ssl/private-copy
RUN mv -f /etc/ssl/private/* /etc/ssl/private-copy/
RUN rm -rf /etc/ssl/private 
RUN mv -f /etc/ssl/private-copy /etc/ssl/private
RUN chmod -R go-rwx /etc/ssl/private && chown -R postgres /etc/ssl/private

ADD postgresql.conf /etc/postgresql/9.4/main/postgresql.conf
ADD pg_hba.conf /etc/postgresql/9.4/main/pg_hba.conf
RUN chown postgres:postgres /etc/postgresql/9.4/main/*.conf

ADD start /opt/postgres/start
RUN chmod a+x /opt/postgres/start

ENTRYPOINT ["/opt/postgres/start"]
