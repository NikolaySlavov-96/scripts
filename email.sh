#!/bin/bash

send_email() {
    if [ "$#" -lt 2 ]; then
        echo "Usage: send_email recipient@example.com 'Your message here'"
        exit 1
    fi

    local recipient="$1"
    local message="$2"
    local type="$3"

    local email_content=$(
        cat <<EOF
From: ${type:- "Success"} Notification
To: $recipient
Subject: Automated Email

$message
EOF
    )

    echo -e "$email_content" | ssmtp "$recipient"
}
