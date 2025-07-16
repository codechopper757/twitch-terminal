#!/bin/bash

# Load secrets
if [[ -f .env ]]; then
    export $(grep -v '^#' .env | xargs)
fi

# Check deps
for cmd in curl jq fzf streamlink mpv kitty; do
    command -v $cmd &>/dev/null || { echo "$cmd is required"; exit 1; }
done

# Step 1: Get your user ID
user_id=$(curl -s -H "Client-ID: $TWITCH_CLIENT_ID" \
                -H "Authorization: Bearer $TWITCH_OAUTH_TOKEN" \
                "https://api.twitch.tv/helix/users" | jq -r '.data[0].id')

# Step 2: Get live followed streams
live_streams=$(curl -s -H "Client-ID: $TWITCH_CLIENT_ID" \
                    -H "Authorization: Bearer $TWITCH_OAUTH_TOKEN" \
                    "https://api.twitch.tv/helix/streams/followed?user_id=$user_id" | \
              jq -r '.data[] | "\(.user_name) [\(.game_name)] \(.title)"')

# Step 3: Add "Custom..." fallback
options=$(printf "%s\nCustom..." "$live_streams")

# Step 4: fzf selection
selected=$(echo "$options" | fzf --prompt="Choose stream: ")

# Handle custom input
if [[ "$selected" == "Custom..." ]]; then
    read -p "Enter Twitch channel name: " selected
else
    # Extract channel name (first word before first space)
    selected=$(echo "$selected" | awk '{print $1}')
fi

# Launch chat and stream
kitty --title="Twitch Chat: $selected" /usr/bin/twt --channel "$selected" &
streamlink --player mpv "twitch.tv/$selected" best
