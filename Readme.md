# OpenVPN

A [Docker](http://docker.com) file to build images for AMD & ARM devices with a installation of [OpenVPN](https://openvpn.net/) VPN server to secure your data communications, whether it's for Internet privacy, remote access for employees, securing IoT, or for networking Cloud data centers.

> Be aware! You should read carefully the usage documentation of every tool!

## Thanks to

- [OpenVPN](https://openvpn.net/)
- [Kyle Manna](https://github.com/kylemanna/docker-openvpn)

## Details

- [GitHub](https://github.com/DeftWork/openvpn)
- [Deft.Work my personal blog](http://deft.work)

| Docker Hub | Docker Pulls | Docker Stars | Docker Build | Size/Layers |
| --- | --- | --- | --- | --- |
| [OpenVPN](https://hub.docker.com/r/elswork/openvpn "elswork/openvpn on Docker Hub") | [![](https://img.shields.io/docker/pulls/elswork/openvpn.svg)](https://hub.docker.com/r/elswork/openvpn "openvpn on Docker Hub") | [![](https://img.shields.io/docker/stars/elswork/openvpn.svg)](https://hub.docker.com/r/elswork/openvpn "OpenVPN on Docker Hub") | [![](https://img.shields.io/docker/build/elswork/openvpn.svg)](https://hub.docker.com/r/elswork/openvpn "OpenVPN on Docker Hub") | [![](https://images.microbadger.com/badges/image/elswork/openvpn.svg)](https://microbadger.com/images/elswork/openvpn "OpenVPN on microbadger.com") |

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
docker run -v ovpn-data-sample:/etc/openvpn --log-driver=none --rm elswork/openvpn ovpn_genconfig -u udp://YourServerDomain.com
``` 

### Init PKI

``` sh
make pki
``` 
Or
``` sh
docker run -v ovpn-data-sample:/etc/openvpn --log-driver=none --rm -it elswork/openvpn ovpn_initpki
```

### Start VPN Server

``` sh
make start
``` 
Or
``` sh
docker run -v ovpn-data-sample:/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN elswork/openvpn
```

### Create ovpn client file

``` sh
make client
``` 
Or
``` sh
docker run -v ovpn-data-sample:/etc/openvpn --log-driver=none --rm -it elswork/openvpn easyrsa build-client-full CLIENTNAME nopass
```

### Retrieve ovpn client file

``` sh
make retrieve
``` 
Or
``` sh
docker run -v ovpn-data-sample:/etc/openvpn --log-driver=none --rm elswork/openvpn ovpn_getclient CLIENTNAME > CLIENTNAME.ovpn
```

Send the generated ovpn file to your smartphone.

You must have installed [OpenVPN Connect – Fast & Safe SSL VPN Client](https://play.google.com/store/apps/details?id=net.openvpn.openvpn)
