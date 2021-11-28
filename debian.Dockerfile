FROM openjdk:jre-alpine as builder

COPY qemu-arm-static /usr/bin/
COPY qemu-aarch64-static /usr/bin/

FROM builder

ARG ARCH=armel
ARG VERSION="1.4.2"
LABEL version="${VERSION}-${ARCH}"

COPY ./${ARCH}/*.jar /jdownloader/libs/
ENV XDG_DOWNLOAD_DIR=/jdownloader/downloads

# archive extraction uses sevenzipjbinding library
# which is compiled against libstdc++
RUN apt-get update && \
    apt-get install openjdk-8-jre ffmpeg wget -y && \
    wget -O /jdownloader/JDownloader.jar "http://installer.jdownloader.org/JDownloader.jar?$RANDOM" && \
    chmod 777 /jdownloader/ -R && \
    apt-get autoremove -y && \
    rm /usr/bin/qemu-*-static

COPY daemon.sh /jdownloader/
COPY default-config.json.dist /jdownloader/
COPY configure.sh /usr/bin/configure

EXPOSE 3129

CMD ["/jdownloader/daemon.sh"]
