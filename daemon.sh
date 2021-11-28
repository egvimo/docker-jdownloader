#!/bin/sh

trap 'kill -TERM $PID' TERM INT
rm -f /jdownloader/exec/JDownloader.jar.*
rm -f /jdownloader/exec/JDownloader.pid

# Login user with env credentials - Please prefer command way
if [ -n "$MYJD_USER" ] && [ -n "$MYJD_PASSWORD" ]; then
    configure "$MYJD_USER" "$MYJD_PASSWORD"
fi

# Defining device name to jdownloader interface - please prefer this method than changing on MyJDownloader to keep correct binding
if [ -n "$MYJD_DEVICE_NAME" ]; then
    sed -Ei "s/\"devicename\" : .+\"(,?)/\"devicename\" : \"$MYJD_DEVICE_NAME\"\1/" /jdownloader/exec/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json
fi

# Debugging helper - if the container crashes, create a file called "jdownloader-block.txt" in the download folder
# The container will not terminate (and you can run "docker exec -it ... bash")
if [ -f /jdownloader/downloads/jdownloader-block.txt ]; then
    sleep 1000000
fi

# Check JDownloader.jar integrity and removes it in case it's not
jar tvf /jdownloader/exec/JDownloader.jar > /dev/null 2>&1
if [ $? -ne 0 ]; then
    rm /jdownloader/exec/JDownloader.jar
fi

# Check if JDownloader.jar exists, or if there is an interrupted update
if [ ! -f /jdownloader/exec/JDownloader.jar ] && [ -f /jdownloader/exec/tmp/update/self/JDU/JDownloader.jar ]; then
    cp /jdownloader/exec/tmp/update/self/JDU/JDownloader.jar /jdownloader/exec/
fi

# Recopy if no JDownloader exists
if [ ! -f /jdownloader/exec/JDownloader.jar ]; then
    cp /jdownloader/JDownloader.jar /jdownloader/exec/
fi

# Defines umask - should respect octal format
if echo "$UMASK" | grep -Eq '0[0-7]{3}' ; then
    echo "Defining umask to $UMASK"
    umask "$UMASK"
fi

java -Dsun.jnu.encoding=UTF-8 -Dfile.encoding=UTF-8 -Djava.awt.headless=true -jar /jdownloader/exec/JDownloader.jar -norestart &
PID=$!
wait $PID
wait $PID

EXIT_STATUS=$?
