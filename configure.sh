#!/bin/sh

usage="$(basename "$0") <email> <password>"

if [ ! $# -eq 2 ]; then
    echo "$usage"
    exit 1
fi

if [ ! -f /jdownloader/exec/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json ]; then
    cp /jdownloader/default-config.json.dist /jdownloader/exec/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json
fi

sed -Ei "s/\"password\" : .+\"(,?)/\"password\" : \"$2\"\1/" /jdownloader/exec/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json && \
sed -Ei "s/\"email\" : .+\"(,?)/\"email\" : \"$1\"\1/" /jdownloader/exec/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json
pkill -f "JDownloader"
