FROM openjdk:jre-alpine as builder

COPY qemu-aarch64-static /usr/bin/
COPY qemu-arm-static /usr/bin/

FROM builder

ARG ARCH=armhf
ARG VERSION="1.4.3"
LABEL version="${VERSION}-${ARCH}"
ENV LD_LIBRARY_PATH=/lib;/lib32;/usr/lib
ENV XDG_DOWNLOAD_DIR=/jdownloader/downloads
ENV LC_CTYPE="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LC_COLLATE="C"
ENV LANGUAGE="C.UTF-8"
ENV LC_ALL="C.UTF-8"
ENV UMASK=''
COPY ./${ARCH}/*.jar /jdownloader/libs/
# archive extraction uses sevenzipjbinding library
# which is compiled against libstdc++
RUN apk add --update libstdc++ ffmpeg wget && \
    wget -O /jdownloader/JDownloader.jar "http://installer.jdownloader.org/JDownloader.jar?$RANDOM" && \
    chmod +x /jdownloader/JDownloader.jar && \
    chmod 777 /jdownloader/ -R && \
    rm /usr/bin/qemu-*-static

COPY daemon.sh /jdownloader/
COPY default-config.json.dist /jdownloader/
COPY configure.sh /usr/bin/configure

EXPOSE 3129

CMD ["/jdownloader/daemon.sh"]
