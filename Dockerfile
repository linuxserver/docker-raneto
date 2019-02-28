FROM lsiobase/alpine:3.8

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chbmb"

# environment settings
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	curl \
	g++ \
	gcc \
	libsass-dev \
	make \
	nodejs-npm \
	python \
	tar && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	nodejs && \
 echo "**** update npm and install node dependencies ****" && \
 npm install -g \
	gulp-cli \
	npm@latest \
	pm2 && \
 echo "**** install raneto ****" && \
 mkdir -p \
	/app/raneto && \
 RANETO_VER=$(curl -sX GET "https://api.github.com/repos/gilbitron/Raneto/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]') && \
 curl -o \
 /tmp/raneto-src.tar.gz -L \
	"https://github.com/gilbitron/Raneto/archive/${RANETO_VER}.tar.gz" && \
 tar xf \
 /tmp/raneto-src.tar.gz -C \
	/app/raneto --strip-components=1 && \
 cd /app/raneto && \
 echo "**** install raneto node dev modules and build ****" && \
 npm install && \
 gulp && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root \
	/tmp/* && \
 mkdir -p \
	/root

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 3000
VOLUME /config
