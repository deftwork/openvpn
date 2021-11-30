SNAME ?= openvpn
RNAME ?= elswork/$(SNAME)
ONAME ?= deftwork/$(SNAME)
VER ?= `cat VERSION`
BASE ?= latest
BASENAME ?= alpine:$(BASE)
TARGET_PLATFORM ?= linux/amd64,linux/arm64,linux/ppc64le,linux/s390x,linux/386,linux/arm/v7,linux/arm/v6
# linux/amd64,linux/arm64,linux/ppc64le,linux/s390x,linux/arm/v7,linux/arm/v6
NO_CACHE ?= 
# NO_CACHE ?= --no-cache
#MODE ?= debug
MODE ?= $(VER)
OVPN_DATA ?= ovpn-data
SERVERNAME ?= deft.work

# HELP
# This will output the help for each task

.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# DOCKER TASKS

# Build image

debug: ## Debug the container
	docker build -t $(RNAME):debug \
	--build-arg BASEIMAGE=$(BASENAME) \
	--build-arg VERSION=$(VER) .
build: ## Build the container
	mkdir -p builds
	docker build $(NO_CACHE) -t $(RNAME):$(VER) -t $(RNAME):latest \
	--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
	--build-arg VCS_REF=`git rev-parse --short HEAD` \
	--build-arg BASEIMAGE=$(BASENAME) \
	--build-arg VERSION=$(VER) \
	. > builds/$(VER)_`date +"%Y%m%d_%H%M%S"`.txt
bootstrap: ## Start multicompiler
	docker buildx inspect --bootstrap
debugx: ## Buildx in Debug mode
	docker buildx build \
	--platform ${TARGET_PLATFORM} \
	-t $(RNAME):debug --pull \
	--build-arg BASEIMAGE=$(BASENAME) \
	--build-arg VERSION=$(VER) .
buildx: ## Buildx the container
	docker buildx build $(NO_CACHE) \
	--platform ${TARGET_PLATFORM} \
	-t ghcr.io/$(ONAME):$(VER) -t ghcr.io/$(ONAME):latest \
	-t $(RNAME):$(VER) -t $(RNAME):latest --pull --push \
	--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
	--build-arg VCS_REF=`git rev-parse --short HEAD` \
	--build-arg BASEIMAGE=$(BASENAME) \
	--build-arg VERSION=$(VER) .

# Operations

console: ## Start console in container
	docker run -it --rm --entrypoint "/bin/ash" $(RNAME):$(MODE)
volume: ## Create Volume
	docker volume create --name $(OVPN_DATA)
config: ## Generate configuration
	docker run -v $(OVPN_DATA):/etc/openvpn --log-driver=none --rm $(RNAME):$(MODE) ovpn_genconfig -u udp://$(SERVERNAME)
pki: ## Init PKI
	docker run -v $(OVPN_DATA):/etc/openvpn --log-driver=none --rm -it $(RNAME):$(MODE) touch /etc/openvpn/vars
	docker run -v $(OVPN_DATA):/etc/openvpn --log-driver=none --rm -it $(RNAME):$(MODE) ovpn_initpki
init: volume config pki ## Execute volume, config, pki all together
start: ## Start VPN Server
	docker run -v $(OVPN_DATA):/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN $(RNAME):$(MODE)
client: ## Create ovpn client file
	docker run -v $(OVPN_DATA):/etc/openvpn --log-driver=none --rm -it $(RNAME):$(MODE) easyrsa build-client-full CLIENTNAME nopass
retrieve: ## Retrieve ovpn client file
	docker run -v $(OVPN_DATA):/etc/openvpn --log-driver=none --rm $(RNAME):$(MODE) ovpn_getclient CLIENTNAME > CLIENTNAME.ovpn