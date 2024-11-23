#!/bin/bash

DIRECTORY_NAME="Reports"
if [ -d "$DIRECTORY_NAME" ]; then
    echo "Directory $DIRECTORY_NAME exist"
else
    mkdir "$DIRECTORY_NAME"
fi

LOGS_LOG="logs.log"
if [ -f "$LOGS_LOG" ]; then
    echo "Directory $LOGS_LOG exist"
else
    touch "$LOGS_LOG"
fi

LOGS_TXT="logs.txt"
if [ -f "$LOGS_TXT" ]; then
    echo "Directory $LOGS_TXT exist"
else
    touch "$LOGS_TXT"
fi