FROM phusion/baseimage
MAINTAINER Niclas Kühne <nk@plaxon.de>

RUN apt-get update && \
	apt-get install -y apt-transport-https wget curl locales

# Configure timezone and locale
RUN echo "Europe/Berlin" > /etc/timezone && \
	dpkg-reconfigure -f noninteractive tzdata
RUN export LANGUAGE=de_DE.UTF-8 && \
	export LANG=de_DE.UTF-8 && \
	export LC_ALL=de_DE.UTF-8 && \
	locale-gen de_DE.UTF-8 && \
	dpkg-reconfigure locales
	
RUN echo "deb https://sernet-samba-public:Noo1oxe4zo@download.sernet.de/packages/samba/4.2/ubuntu trusty main" >> /etc/apt/sources.list.d/sernet-samba-4.2.list
RUN echo "deb-src https://sernet-samba-public:Noo1oxe4zo@download.sernet.de/packages/samba/4.2/ubuntu trusty main" >> /etc/apt/sources.list.d/sernet-samba-4.2.list

RUN wget http://ftp.sernet.de/pub/sernet-samba-keyring_1.5_all.deb
RUN dpkg --install sernet-samba-keyring_1.5_all.deb

RUN apt-get update && \
	apt-get install -y \
        sernet-samba-ad \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add startup scripts
RUN mkdir -p /etc/my_init.d
COPY samba_setup.sh /etc/my_init.d/

# Add services
RUN mkdir /etc/service/samba
COPY samba_run.sh /etc/service/samba/run
COPY samba_finish.sh /etc/service/samba/finish
RUN chmod +x /etc/service/samba/run
RUN chmod +x /etc/service/samba/finish
RUN chown root:root /etc/service/samba/run
RUN chown root:root /etc/service/samba/finish

VOLUME ["/var/lib/samba"]

CMD ["/sbin/my_init"]

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*