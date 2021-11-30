# OpenVPN

A [Docker](http://docker.com) file to build images for AMD & ARM devices with an installation of [OpenVPN](https://openvpn.net/) VPN server to secure your data communications, whether it's for Internet privacy, remote access for employees, securing IoT, or for networking Cloud data centers.

> Be aware! You should carefully read the usage documentation of every tool!

## Thanks to

- [OpenVPN](https://openvpn.net/)
- [Kyle Manna](https://github.com/kylemanna/docker-openvpn)

## Details

| Website | GitHub | Docker Hub |
| --- | --- | --- |
| [Deft.Work my personal blog](https://deft.work) | [openvpn](https://github.com/DeftWork/openvpn) | [openvpn](https://hub.docker.com/r/elswork/openvpn) |

| Docker Pulls | Docker Stars | Size | Sponsors |
| --- | --- | --- | --- |
| [![Docker pulls](https://img.shields.io/docker/pulls/elswork/openvpn.svg)](https://hub.docker.com/r/elswork/openvpn "openvpn on Docker Hub") | [![Docker stars](https://img.shields.io/docker/stars/elswork/openvpn.svg)](https://hub.docker.com/r/elswork/openvpn "openvpn on Docker Hub") | [![Docker Image size](https://img.shields.io/docker/image-size/elswork/openvpn)](https://hub.docker.com/r/elswork/openvpn "openvpn on Docker Hub") | [![GitHub Sponsors](https://img.shields.io/github/sponsors/elswork)](https://github.com/sponsors/elswork "Sponsor me!") |

## Compatible Architectures

This image has been builded using [buildx](https://docs.docker.com/buildx/working-with-buildx/) for these architectures: 
- amd64 arm64 ppc64le s390x 386 arm/v7 arm/v6

## Build Instructions

Build for amd64 arm64 or armv7l architecture (thanks to its [Multi-Arch](https://blog.docker.com/2017/11/multi-arch-all-the-things/) base image)

``` sh
docker build -t elswork/openvpn .
```

## Usage

The process to get a full fuctional VPN server and a suitable ovpn client file involve 6 steps:

### Create Volume

``` sh
make volume
``` 
Or
``` sh
docker volume create --name ovpn-data-sample
``` 

### Generate Configuration

``` sh
make config
``` 
Or
``` sh
docker run -v ovpn-data-sample:/etc/openvpn \
    --log-driver=none --rm elswork/openvpn ovpn_genconfig \
    -u udp://YourServerDomain.com
``` 

### Initialize PKI

``` sh
make pki
``` 
Or
``` sh
docker run -v ovpn-data-sample:/etc/openvpn \
    --log-driver=none --rm -it elswork/openvpn touch /etc/openvpn/vars
docker run -v ovpn-data-sample:/etc/openvpn \
    --log-driver=none --rm -it elswork/openvpn ovpn_initpki
```

### Init

You can execute earlier three steps (Create Volume, Generate Configuration and Initialize PKI) in a single make command.

``` sh
make init
```

### Start VPN Server

``` sh
make start
``` 
Or
``` sh
docker run -v ovpn-data-sample:/etc/openvpn \
    -d -p 1194:1194/udp --cap-add=NET_ADMIN elswork/openvpn
```

### Create ovpn client file

``` sh
make client
``` 
Or
``` sh
docker run -v ovpn-data-sample:/etc/openvpn \
    --log-driver=none --rm -it elswork/openvpn easyrsa build-client-full CLIENTNAME nopass
```

### Retrieve ovpn client file

``` sh
make retrieve
``` 
Or
``` sh
docker run -v ovpn-data-sample:/etc/openvpn \
    --log-driver=none --rm elswork/openvpn \
    ovpn_getclient CLIENTNAME > CLIENTNAME.ovpn
```

After this command a file called "CLIENTNAME.ovpn" should be created in the current path, this file in the client configuration file for this VPN server, it must be sent to the client device that will connect to the VPN, sometimes it can be difficult to send that file out of the linux system, I suggest to send it via mail if you have an operative mail system in your linux host or using SFTP, FTP, SCP, or [Samba](https://hub.docker.com/r/elswork/samba). Send the generated ovpn file to your smartphone or client device.

You must have installed [OpenVPN Connect](https://openvpn.net/download-open-vpn/)

---
**[Sponsor me!](https://github.com/sponsors/elswork) Together we will be unstoppable.**