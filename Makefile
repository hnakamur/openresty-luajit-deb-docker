PKG_VERSION=2.1.20231117
PKG_REL_PREFIX=1hn1
ifdef NO_CACHE
DOCKER_NO_CACHE=--no-cache
endif

# Ubuntu 22.04
deb-ubuntu2204: build-ubuntu2204
	docker run --rm -v ./dist-ubuntu2204:/dist luajit-ubuntu2204 bash -c \
	"install /src/*${PKG_VERSION}* /dist/"
	tar zcf dist-ubuntu2204.tar.gz ./dist-ubuntu2204/

build-ubuntu2204:
	sudo mkdir -p dist-ubuntu2204
	PKG_REL_DISTRIB=ubuntu22.04; \
	(set -x; BUILDKIT_PROGRESS=plain docker build ${DOCKER_NO_CACHE} \
	    --build-arg FROM=ubuntu:22.04 \
		--build-arg PKG_VERSION=${PKG_VERSION} \
		--build-arg PKG_REL_DISTRIB=ubuntu22.04 \
		-t luajit-ubuntu2204 . \
	) 2>&1 | sudo tee dist-ubuntu2204/luajit_${PKG_VERSION}-${PKG_REL_PREFIX}$${PKG_REL_DISTRIB}.build.log&& \
	sudo xz --best --force dist-ubuntu2204/luajit_${PKG_VERSION}-${PKG_REL_PREFIX}$${PKG_REL_DISTRIB}.build.log

run-ubuntu2204:
	docker run --rm -it luajit-ubuntu2204 bash

# Debian 12
deb-debian12: build-debian12
	docker run --rm -v ./dist-debian12:/dist luajit-ubuntu2204 bash -c \
	"install /src/*${PKG_VERSION}* /dist/"
	tar zcf dist-debian12.tar.gz ./dist-debian12/

build-debian12:
	sudo mkdir -p dist-debian12
	PKG_REL_DISTRIB=debian12; \
	(set -x; BUILDKIT_PROGRESS=plain docker build ${DOCKER_NO_CACHE} \
	    --build-arg FROM=debian:12 \
		--build-arg PKG_VERSION=${PKG_VERSION} \
		--build-arg PKG_REL_DISTRIB=debian12 \
		-t luajit-debian12 . \
	) 2>&1 | sudo tee dist-debian12/luajit_${PKG_VERSION}-${PKG_REL_PREFIX}$${PKG_REL_DISTRIB}.build.log && \
	sudo xz --best --force dist-debian12/luajit_${PKG_VERSION}-${PKG_REL_PREFIX}$${PKG_REL_DISTRIB}.build.log

run-debian12:
	docker run --rm -it luajit-debian12 bash

exec:
	docker exec -it $$(docker ps -q) bash

.PHONY: deb-debian12 run-debian12 build-debian12 deb-ubuntu2204 run-ubuntu2204 build-ubuntu2204 exec
