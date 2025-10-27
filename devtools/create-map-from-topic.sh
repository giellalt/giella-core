#!/bin/bash

# Script to create a map from repositories with a specific topic
# Usage: create-map-from-topic.sh <topic>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <topic>" >&2
    exit 1
fi

TOPIC="$1"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get list of repositories with the specified topic
REPOS=$(${SCRIPT_DIR}/gut-scripts/get-repos-with-topic.sh "$TOPIC" 2>/dev/null)

if [ -z "$REPOS" ]; then
    echo "No repositories found with topic: $TOPIC" >&2
    exit 1
fi

# Convert newline-separated list to space-separated arguments
REPO_ARGS=$(echo "$REPOS" | tr '\n' ' ')

# Call combine-maps.bash with the repositories
${SCRIPT_DIR}/combine-maps.bash $REPO_ARGS
