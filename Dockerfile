# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.22

# set version label
ARG BUILD_DATE
ARG VERSION
ARG RANETO_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

ENV PORT=3000 

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    libsass-dev \
    npm && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    nodejs && \
  echo "**** install raneto ****" && \
  mkdir -p \
    /app/raneto && \
  if [ -z ${RANETO_RELEASE+x} ]; then \
    RANETO_RELEASE=$(curl -sX GET "https://api.github.com/repos/ryanlelek/Raneto/releases/latest" \
      | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/raneto-src.tar.gz -L \
    "https://github.com/ryanlelek/Raneto/archive/${RANETO_RELEASE}.tar.gz" && \
  tar xf \
    /tmp/raneto-src.tar.gz -C \
    /app/raneto --strip-components=1 && \
  echo "**** install raneto node dev modules and build ****" && \
  cd /app/raneto && \
  sed -i \
    's/upgradeInsecureRequests: \[\]/upgradeInsecureRequests: null/g' \
    app/index.js && \
  npm install --omit=dev && \
  mkdir sessions && \
  rm -f config/config.js && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    $HOME/.npm \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 3000

VOLUME /config
