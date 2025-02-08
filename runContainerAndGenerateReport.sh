#!/bin/bash

# Create file and directories
./createLogDirs.sh

source ./logger.sh
source ./email.sh

RECIPIENT_ADDRESS=nikolay.slavov.96@gmail.com

UP_CONTAINER=$(docker ps | grep mongo)
# Exit if no MongoDB container is running
if [ -z "$UP_CONTAINER" ]; then
    message="Mongo container is not exit $UP_CONTAINER"

    log_message "$message"
    send_email "$RECIPIENT_ADDRESS" "$message" "Alert"
    exit 1
fi

FILE_NAME=".env"
if [ -f "$FILE_NAME" ]; then
    echo "File: $FILE_NAME exist"
else
    message="$FILE_NAME file is not exist"

    log_message "$message"
    send_email "$RECIPIENT_ADDRESS" "$message" "Alert"
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

sleep 10s

send_email $RECIPIENT_ADDRESS "Successfully finish script notification"

echo "This is a Log files" | mutt -e "set realname='Logs'" -s "Successfully finish script -> Log files" -a ./logs.log ./logs.txt -- "$RECIPIENT_ADDRESS"

date=$(date +"%Y-%m-%dT%H:%M:%SZ")

REPORT_FOLDER="Reports"

REPORT_NAME="reports-$date.tar.gz"

tar -czvf "$REPORT_NAME" ./$REPORT_FOLDER

echo "This is archive with Reports for date: $date" | mutt -e "set realname='Reports'" -s "Final result from reports" -a ./"$REPORT_NAME" -- "$RECIPIENT_ADDRESS"

sleep 5s

rm -rf $REPORT_FOLDER
