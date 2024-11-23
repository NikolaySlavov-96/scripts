#!/bin/bash

# Get from env file address and collection
set -a
source .env
set +a

LOG_FILE="logs.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >>"$LOG_FILE"
}

FIELDS_ARR=("userBrowser" "urlAddress" "userIpAddress")

for field in "${FIELDS_ARR[@]}"; do
    node uniqueRecordReportGenerator.js "$DATABASE_URL" "$DATABASE_NAME" "$COLLECTION_NAME" "$field"

    NODE_EXIT_CODE="$?"
    echo "$NODE_EXIT_CODE"

    if [ "$NODE_EXIT_CODE" -ne 0 ]; then
        log_message "You have a problem with script $field!"
        exit 1
    fi
done

# This solution is designed to work on other Linux systems.
# yesterday="$(date -d "yesterday" '+%Y-%m-%d')"

# This solution is compatible with and functions effectively on Alpine Linux
yesterday_timestamp=$(($(date +%s) - 86400))
yesterday=$(date -u -I -d @$yesterday_timestamp)

node dateBasedRecordRemover.js "$DATABASE_URL" "$DATABASE_NAME" "$COLLECTION_NAME" "$yesterday"

# node my_script.js --env="$MY_VAR"