#!/bin/bash

LOG_FILE="logs.log"

log_message() {
    echo "$(date -u '+%Y-%m-%d %H:%M:%S.%3NZ') - $1" >>"$LOG_FILE"
}
