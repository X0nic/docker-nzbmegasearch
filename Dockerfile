FROM phusion/baseimage:0.9.15
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh
ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root
ENV TERM screen
MAINTAINER x0nic <nathan@globalphobia.com>

ENV MEGA_VERSION 0.46

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Use specified version of sonarr for more consistent builds
RUN apt-get update -q \
  && apt-get install -qy wget python \
  ; apt-get clean \
  ; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /opt/NZBmegasearch \
  ; mkdir -p /config \
  && chown -R nobody:users /config \
  ; wget -P /tmp/ https://github.com/pillone/usntssearch/archive/v$MEGA_VERSION.tar.gz \
  && tar -C /opt -xvf /tmp/v$MEGA_VERSION.tar.gz --strip-components 1 \
  && chown -R nobody:users /opt/NZBmegasearch

VOLUME /config

# megasearch doesn't have a handy config file command line argument
RUN ln -s /config/custom_params.ini /opt/NZBmegasearch/custom_params.ini

EXPOSE 5000

# Add nzbmegasearch to runit
RUN mkdir /etc/service/nzbmegasearch
ADD nzbmegasearch.sh /etc/service/nzbmegasearch/run
RUN chmod +x /etc/service/nzbmegasearch/run
