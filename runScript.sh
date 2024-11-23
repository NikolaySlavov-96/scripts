#!/bin/bash

# Send email notification
UP_CONTAINER=$(docker ps | grep mongo)
# Exit if no MongoDB container is running
if [ -z "$UP_CONTAINER" ]; then
    echo "$UP_CONTAINER"
    # Mongo container is not exit
    exist 1
fi

DIRECTORY_NAME="Reports"
if [ -d "$DIRECTORY_NAME" ]; then
    echo "Directory $DIRECTORY_NAME exist"
else
    mkdir "$DIRECTORY_NAME"
fi

# Send email notification
FILE_NAME=".env"
if [ -f "$FILE_NAME" ]; then
    echo "File: $FILE_NAME exist"
else
    # .env file is not exist
    exit 1
fi

CONTAINER_IMAGE="clear-mask:latest"

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
    docker build -t "$CONTAINER_IMAGE" .
    run_container
else
    docker build -t "$CONTAINER_IMAGE" .
    # OR
    # docker pull "$VALIDATED_IMAGE"
    run_container
fi

# docker run --name your-container-name -p 3000:3000 -e NODE_ENV=production your-image-name
