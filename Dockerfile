FROM debian:jessie
MAINTAINER Niclas Kühne <nk@plaxon.de>

RUN echo "deb https://sernet-samba-public:Noo1oxe4zo@download.sernet.de/packages/samba/4.2/debian jessie main" >> /etc/apt/sources.list.d/sernet-samba-4.2.list
RUN echo "deb-src https://sernet-samba-public:Noo1oxe4zo@download.sernet.de/packages/samba/4.2/debian jessie main" >> /etc/apt/sources.list.d/sernet-samba-4.2.list

RUN apt-get install -y apt-transport-https wget

RUN wget http://ftp.sernet.de/pub/sernet-samba-keyring_1.5_all.deb
RUN dpkg --install sernet-samba-keyring_1.5_all.deb

RUN apt-get update && apt-get install -y \
        sernet-samba-ad \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add startup scripts
RUN mkdir -p /etc/my_init.d
COPY samba_setup.sh /etc/my_init.d/

# Add services
RUN mkdir /etc/service
RUN mkdir /etc/service/samba
COPY samba_run.sh /etc/service/samba/run
COPY samba_finish.sh /etc/service/samba/finish

VOLUME ["/var/lib/samba"]

CMD ["/sbin/my_init"]