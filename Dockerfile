# syntax=docker/dockerfile:1
ARG FROM=ubuntu:22.04
FROM ${FROM}

# Apapted from
# https://github.com/apache/trafficserver/blob/e4ff6cab0713f25290a62aba74b8e1a595b7bc30/ci/docker/deb/Dockerfile#L46-L58
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install tzdata apt-utils && \
    # Compilers
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
    gcc make pkg-config \
    # tools to create deb packages
    debhelper dpkg-dev lsb-release xz-utils \
    # tools needed to build luajit deb
    git

ARG SRC_DIR=/src
ARG BUILD_USER=build
RUN useradd -m -d ${SRC_DIR} ${BUILD_USER}

COPY --chown=${BUILD_USER}:${BUILD_USER} ./luajit /src/luajit/
USER ${BUILD_USER}
WORKDIR ${SRC_DIR}
ARG PKG_VERSION
RUN tar cf - --exclude=.git luajit | xz -c --best > luajit_${PKG_VERSION}.orig.tar.xz

COPY --chown=${BUILD_USER}:${BUILD_USER} ./debian /src/luajit/debian/
WORKDIR ${SRC_DIR}/luajit
ARG PKG_REL_DISTRIB
RUN sed -i "s/DebRelDistrib/${PKG_REL_DISTRIB}/;s/DebRelCodename/$(lsb_release -cs)/" /src/luajit/debian/changelog
RUN dpkg-buildpackage -us -uc

USER root
