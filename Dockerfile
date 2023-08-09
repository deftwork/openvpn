ARG BASEIMAGE=alpine:3.18.3
FROM ${BASEIMAGE}

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL mantainer="Eloy Lopez <elswork@gmail.com>" \
    org.opencontainers.image.title=openvpn \
    org.opencontainers.image.description="My Multiarch Openvpn Docker recipe" \
    org.opencontainers.image.vendor=Deft.Work \
    org.opencontainers.image.url=https://deft.work/openvpn \
    org.opencontainers.image.source=https://github.com/DeftWork/openvpn \
    org.opencontainers.image.version=$VERSION \ 
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.licenses=MIT

# Testing: pamtester
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update openvpn iptables bash easy-rsa openvpn-auth-pam google-authenticator pamtester libqrencode && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/* 

# Needed by scripts
ENV OPENVPN=/etc/openvpn \
    EASYRSA=/usr/share/easy-rsa \
    EASYRSA_CRL_DAYS=3650 \
    EASYRSA_PKI=/etc/openvpn/pki \
    EASYRSA_VARS_FILE=/etc/openvpn/vars

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["ovpn_run"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/* 

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/