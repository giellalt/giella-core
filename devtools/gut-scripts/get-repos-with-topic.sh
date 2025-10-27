#!/bin/bash

# Script to get repositories with a specific topic
# Usage: get-repos-with-topic.sh <topic>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <topic>" >&2
    exit 1
fi

TOPIC="$1"

# Get all repositories matching ^lang-s and their topics
gut topic get -r ^lang-s | while read -r line; do
    # Extract repository name from lines like:
    # List of topics for lang-sma is: ["topic1", "topic2", ...]
    if [[ "$line" =~ ^List\ of\ topics\ for\ ([^\ ]+)\ is:\ \[(.+)\] ]]; then
        repo="${BASH_REMATCH[1]}"
        topics="${BASH_REMATCH[2]}"
        
        # Check if the desired topic is in the list
        if echo "$topics" | grep -q "\"$TOPIC\""; then
            echo "$repo"
        fi
    fi
done
