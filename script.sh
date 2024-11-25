#!/bin/bash

# Get from env file address and collection
set -a
source .env
set +a

source ./logger.sh

FIELDS_ARR=("userBrowser" "urlAddress" "userIpAddress")

for field in "${FIELDS_ARR[@]}"; do
    log_message "Start on uniqueRecordReportGenerator"
    node uniqueRecordReportGenerator.js "$DATABASE_URL" "$DATABASE_NAME" "$COLLECTION_NAME" "$field"
    log_message "Final on uniqueRecordReportGenerator"

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

log_message "Start on dateBasedRecordRemover"
node dateBasedRecordRemover.js "$DATABASE_URL" "$DATABASE_NAME" "$COLLECTION_NAME" "$yesterday"
log_message "Final on dateBasedRecordRemover"
# node my_script.js --env="$MY_VAR"
