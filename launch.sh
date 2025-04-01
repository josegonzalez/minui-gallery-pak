#!/bin/sh
PAK_DIR="$(dirname "$0")"
PAK_NAME="$(basename "$PAK_DIR")"
PAK_NAME="${PAK_NAME%.*}"
set -x

rm -f "$LOGS_PATH/$PAK_NAME.txt"
exec >>"$LOGS_PATH/$PAK_NAME.txt"
exec 2>&1

echo "$0" "$@"
cd "$PAK_DIR" || exit 1
mkdir -p "$USERDATA_PATH/$PAK_NAME"

architecture=arm
if uname -m | grep -q '64'; then
    architecture=arm64
fi

export PATH="$PAK_DIR/bin/$architecture:$PAK_DIR/bin/$PLATFORM:$PAK_DIR/bin:$PATH"

show_message() {
    message="$1"
    seconds="$2"

    if [ -z "$seconds" ]; then
        seconds="forever"
    fi

    killall minui-presenter >/dev/null 2>&1 || true
    echo "$message" 1>&2
    if [ "$seconds" = "forever" ]; then
        minui-presenter --message "$message" --timeout -1 &
    else
        minui-presenter --message "$message" --timeout "$seconds"
    fi
}

cleanup() {
    rm -f /tmp/stay_awake
    rm -f /tmp/screenshots
    rm -f /tmp/screenshots.list
    rm -f /tmp/screenshots.json
    killall minui-presenter >/dev/null 2>&1 || true
}

main() {
    echo "1" >/tmp/stay_awake
    trap "cleanup" EXIT INT TERM HUP QUIT

    if [ "$PLATFORM" = "tg3040" ] && [ -z "$DEVICE" ]; then
        export DEVICE="brick"
        export PLATFORM="tg5040"
    fi

    allowed_platforms="tg5040 rg35xxplus"
    if ! echo "$allowed_platforms" | grep -q "$PLATFORM"; then
        show_message "$PLATFORM is not a supported platform" 2
        return 1
    fi

    if ! command -v minui-presenter >/dev/null 2>&1; then
        echo "minui-presenter not found" >&2
        return 1
    fi

    chmod +x "$PAK_DIR/bin/$architecture/jq"
    chmod +x "$PAK_DIR/bin/$PLATFORM/minui-presenter"

    mkdir -p "$SDCARD_PATH/Screenshots"
    if [ ! -d "$SDCARD_PATH/Screenshots" ]; then
        show_message "Screenshots directory not found" 2
        return 1
    fi

    if [ -z "$(ls -A "$SDCARD_PATH/Screenshots")" ]; then
        show_message "No screenshots found" 2
        return 1
    fi

    find "$SDCARD_PATH/Screenshots" -maxdepth 1 -type f >/tmp/screenshots
    touch /tmp/screenshots.list
    while read -r file; do
        echo "$(basename "$file")" >>/tmp/screenshots.list
    done </tmp/screenshots
    rm -f /tmp/screenshots
    cat /tmp/screenshots.list | jq -R -s --arg base "$SDCARD_PATH/Screenshots" 'split("\n")[:-1] | {
        items: map({
            text: .,
            background_image: ($base + "/" + .),
            show_pill: true,
            alignment: "top"
        }),
        selected: 0
    }' >/tmp/screenshots.json

    killall minui-presenter >/dev/null 2>&1 || true
    minui-presenter \
        --cancel-show \
        --cancel-text "EXIT" \
        --timeout 0 \
        --font-size-default 12 \
        --file /tmp/screenshots.json
}

main "$@"
