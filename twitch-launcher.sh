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
    selected=$(echo "$selected" | awk '{print $1}')
fi

# Notify about ad pause behavior
echo "Note: Twitch ads will cause short stream pauses. This is normal."

# Launch chat and stream
kitty --title="Twitch Chat: $selected" /usr/bin/twt --channel "$selected" &

# Function to run streamlink with ad detection and yad popup
run_stream_with_ad_timer() {
    streamlink --player mpv "twitch.tv/$1" best 2>&1 | while read -r line; do
        echo "$line"

        if [[ "$line" =~ Detected\ advertisement\ break\ of\ ([0-9]+)\ seconds ]]; then
            duration="${BASH_REMATCH[1]}"
            (
                for ((i=duration; i>0; i--)); do
                    echo "# Twitch ad break: $i seconds remaining"
                    echo "$((100 - (i * 100 / duration)))"
                    sleep 1
                done
            ) | yad --progress \
                    --title="Twitch Ad Break" \
                    --percentage=0 \
                    --auto-close \
                    --no-buttons \
                    --width=300 \
                    --on-top \
                    --center &
        fi
    done
}

# Run the stream

run_stream_with_ad_timer "$selected"
