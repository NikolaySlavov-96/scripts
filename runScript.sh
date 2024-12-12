#!/bin/bash

# Create file and directories
./createLogDirs.sh

source ./logger.sh
source ./email.sh

recipient=nikolay.slavov.96@gmail.com

UP_CONTAINER=$(docker ps | grep mongo)
# Exit if no MongoDB container is running
if [ -z "$UP_CONTAINER" ]; then
    message="Mongo container is not exit $UP_CONTAINER"

    log_message "$message"
    send_email "$recipient" "$message" "Alert"
    exit 1
fi

FILE_NAME=".env"
if [ -f "$FILE_NAME" ]; then
    echo "File: $FILE_NAME exist"
else
    message="$FILE_NAME file is not exist"

    log_message "$message"
    send_email "$recipient" "$message" "Alert"
    exit 1
fi

CONTAINER_IMAGE="clear-mask"

function run_container() {
    # docker run --rm \
    #     --env-file .env \
    #     -v ./config.json:/urs/app/config.json \
    #     -v ./Reports:/urs/app/Reports:rw \
    #     -v ./logs.log:/urs/app/logs.log:rw \
    #     -v ./logs.txt:/urs/app/logs.txt:rw "$CONTAINER_IMAGE"
    IMAGE_NAME="$CONTAINER_IMAGE" docker-compose up -d
}

VALIDATED_IMAGE=$(docker images | grep "$CONTAINER_IMAGE")
# CONTAINER_IMAGE container is running
if [ -n "$VALIDATED_IMAGE" ]; then
    log_message "Run -> $CONTAINER_IMAGE"
    run_container
else
    log_message "Start build or pull on $CONTAINER_IMAGE"
    docker build -t "$CONTAINER_IMAGE" .
    # OR
    # docker pull "$VALIDATED_IMAGE"

    log_message "Run after build $CONTAINER_IMAGE"
    run_container
fi

REPORT_FOLDER="Reports"
date=$(date +"%Y-%m-%dT%H:%M:%SZ")
tar -czvf "reports-$date.tar.gz" ./$REPORT_FOLDER

send_email $recipient "Successfully finish script"

sleep 5s
rm -rf $REPORT_FOLDER
