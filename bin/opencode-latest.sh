#!/usr/bin/env bash

CACHE_FILE="$HOME/.cache/opencode-latest"
CACHE_MAX_AGE=86400  # 24 hours in seconds
FALLBACK_VERSION="v1.0.162"

# Ensure cache directory exists
mkdir -p "$(dirname "$CACHE_FILE")"

# Check if cache exists and is fresh
use_cache=false
if [ -f "$CACHE_FILE" ]; then
    cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE")))
    if [ "$cache_age" -lt "$CACHE_MAX_AGE" ]; then
        use_cache=true
    fi
fi

if [ "$use_cache" = true ]; then
    # Use cached version
    LATEST_VERSION=$(cat "$CACHE_FILE")
else
    # Fetch latest version from GitHub API
    LATEST_VERSION=$(curl -s https://api.github.com/repos/sst/opencode/releases/latest | jq -r '.tag_name')

    # Validate the fetched version
    if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" = "null" ]; then
        echo "Warning: Could not fetch latest version from GitHub, using fallback: $FALLBACK_VERSION" >&2
        LATEST_VERSION="$FALLBACK_VERSION"
    else
        # Cache the successfully fetched version
        echo "$LATEST_VERSION" > "$CACHE_FILE"

        echo "Fetching $LATEST_VERSION"
    fi
fi

# Run opencode with the determined version
nix run "github:sst/opencode/${LATEST_VERSION}"
