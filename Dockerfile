FROM lsiobase/alpine:3.11

# set version label
ARG BUILD_DATE
ARG VERSION
ARG RANETO_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

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
 echo "**** install raneto ****" && \
 mkdir -p \
	/app/raneto && \
 if [ -z ${RANETO_RELEASE+x} ]; then \
	RANETO_RELEASE=$(curl -sX GET "https://api.github.com/repos/gilbitron/Raneto/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/raneto-src.tar.gz -L \
	"https://github.com/gilbitron/Raneto/archive/${RANETO_RELEASE}.tar.gz" && \
 tar xf \
 /tmp/raneto-src.tar.gz -C \
	/app/raneto --strip-components=1 && \
 echo "**** install raneto node dev modules and build ****" && \
 cd /app/raneto && \
 npm config set unsafe-perm true && \
 npm install gulp && \
 npm install --production && \
 node node_modules/gulp/bin/gulp.js && \
 npm uninstall gulp && \
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
