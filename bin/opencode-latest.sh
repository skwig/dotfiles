#!/usr/bin/env bash

CACHE_FILE="$HOME/.cache/opencode-latest"
CACHE_MAX_AGE=43200 # 12 hours in seconds
FALLBACK_VERSION="v1.0.223"

# Extract and format bullet points from markdown changelog
extract_changelog() {
    local release_body="$1"

    # Extract lines that start with -, *, or are numbered lists (1., 2., etc.)
    # Stop at "Thank you" section to keep output concise
    echo "$release_body" | sed '/\*\*Thank you/,$d' | grep -E '^\s*[-*]|^\s*[0-9]+\.' | sed 's/^[[:space:]]*/  /' || echo "  (No changelog items found)"
}

# Ensure cache directory exists
mkdir -p "$(dirname "$CACHE_FILE")"

# Track old version for changelog comparison
OLD_VERSION=""
if [ -f "$CACHE_FILE" ]; then
    OLD_VERSION=$(cat "$CACHE_FILE")
fi

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
    # Use temp file to store releases JSON (avoids bash variable issues with JSON control characters)
    RELEASES_TEMP=$(mktemp)
    trap 'rm -f "$RELEASES_TEMP"' EXIT

    curl -s -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/sst/opencode/releases?per_page=5" > "$RELEASES_TEMP"

    LATEST_VERSION=$(jq -r '.[0].tag_name' "$RELEASES_TEMP")

    # Validate the fetched version
    if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" = "null" ]; then
        echo "Warning: Could not fetch latest version from GitHub, using fallback: $FALLBACK_VERSION" >&2
        LATEST_VERSION="$FALLBACK_VERSION"
    else
        # Cache the successfully fetched version
        echo "$LATEST_VERSION" > "$CACHE_FILE"

        # Display changelogs for new releases (up to 5, stop at OLD_VERSION)
        RELEASE_COUNT=$(jq 'length' "$RELEASES_TEMP")

        if [ "$RELEASE_COUNT" -gt 0 ]; then
            echo "================================================================================"
            echo "OpenCode - Recent Releases (https://github.com/sst/opencode/releases)"
            echo "================================================================================"
            echo ""

            for i in $(seq 0 $((RELEASE_COUNT - 1))); do
                VERSION=$(jq -r ".[$i].tag_name" "$RELEASES_TEMP")

                # Stop if we've reached the previously cached version
                if [ -n "$OLD_VERSION" ] && [ "$VERSION" = "$OLD_VERSION" ]; then
                    break
                fi

                PUBLISHED=$(jq -r ".[$i].published_at" "$RELEASES_TEMP")
                BODY=$(jq -r ".[$i].body // \"No release notes available\"" "$RELEASES_TEMP")

                # Format the date (extract just the date part)
                PUBLISH_DATE=$(echo "$PUBLISHED" | cut -d'T' -f1)

                echo "📦 $VERSION ($PUBLISH_DATE)"
                echo "--------------------------------------------------------------------------------"
                extract_changelog "$BODY"
                echo ""
            done

            echo "================================================================================"
            echo ""
        fi

        echo "Fetching $LATEST_VERSION"
    fi
fi

# Run opencode with the determined version
nix run "github:sst/opencode/${LATEST_VERSION}"
