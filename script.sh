#!/bin/bash

# Get from env file address and collection
set -a
source .env
set +a

source ./logger.sh

CONFIG_JSON="config.json"

COLLECTIONS_NAMES=$(jq -r '.collectionsNames[]' "$CONFIG_JSON")

# FIELDS_ARG_ARR=("userBrowser" "urlAddress" "userIpAddress")

for collection in $COLLECTIONS_NAMES; do
    collectionFieldName=$(jq -r --arg col "$collection" '.collectionsFields[$col][]' "$CONFIG_JSON")

    for field in $collectionFieldName; do
        LOG_PREFIX="collection - $collection / field - $field"

        log_message "Start on uniqueRecordReportGenerator: $LOG_PREFIX"
        node uniqueRecordReportGenerator.js "$DATABASE_URL" "$DATABASE_NAME" "$collection" "$field"
        log_message "Final on uniqueRecordReportGenerator: $LOG_PREFIX"

        NODE_EXIT_CODE="$?"
        echo "$NODE_EXIT_CODE"

        if [ "$NODE_EXIT_CODE" -ne 0 ]; then
            log_message "You have a problem with script $field!"
            exit 1
        fi
    done
done

# This solution is designed to work on other Linux systems.
# yesterday="$(date -d "yesterday" '+%Y-%m-%d')"

# This solution is compatible with and functions effectively on Alpine Linux
yesterday_timestamp=$(($(date +%s) - 86400))
yesterday=$(date -u -I -d @$yesterday_timestamp)

log_message "Start on dateBasedRecordRemover"

for collection in $COLLECTIONS_NAMES; do
    node dateBasedRecordRemover.js "$DATABASE_URL" "$DATABASE_NAME" "$collection" "$yesterday"
done

log_message "Final on dateBasedRecordRemover"
# node my_script.js --env="$MY_VAR"
