FROM ubuntu:16.04
MAINTAINER Niclas Kühne <nk@plaxon.de>

# Default environment variables. Please overwrite!

ENV SAMBA_REALM="samba.dom"
ENV SAMBA_PASSWORD="test"
ENV SAMBA_HOST_IP="10.10.10.247"
ENV SAMBA_DNS_FORWARDER="10.10.10.254"

RUN apt-get update && \
	apt-get install -y \
        samba \
		curl \
		locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure timezone and locale
RUN echo "Europe/Berlin" > /etc/timezone && \
	dpkg-reconfigure -f noninteractive tzdata
RUN export LANGUAGE=de_DE.UTF-8 && \
	export LANG=de_DE.UTF-8 && \
	export LC_ALL=de_DE.UTF-8 && \
	locale-gen de_DE.UTF-8 && \
	dpkg-reconfigure locales
	
# Add startup scripts
RUN mkdir -p /etc/my_init.d
COPY samba_setup.sh /etc/my_init.d/
COPY samba_run.sh /etc/my_init.d/
RUN chmod +x /etc/my_init.d/samba_setup.sh
RUN chown root:root /etc/my_init.d/samba_setup.sh
RUN chmod +x /etc/my_init.d/samba_run.sh
RUN chown root:root /etc/my_init.d/samba_run.sh

VOLUME ["/var/lib/samba"]

CMD ["/etc/my_init.d/samba_setup.sh"]

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/etc/my_init.d/samba_run.sh"]

# Expose AD DC Ports
EXPOSE 135/tcp
EXPOSE 137/udp
EXPOSE 138/udp
EXPOSE 139/tcp
EXPOSE 445/tcp
EXPOSE 464/tcp
EXPOSE 464/udp
EXPOSE 389/tcp
EXPOSE 389/udp
EXPOSE 636/tcp
EXPOSE 3268/tcp
EXPOSE 3269/tcp
EXPOSE 53/tcp
EXPOSE 53/udp
EXPOSE 88/tcp
EXPOSE 88/udp