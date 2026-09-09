#!/usr/bin/env bash
set -e

window_is_float() {
    local layout
    layout=$(yabai -m query --spaces --space 2>/dev/null | jq -r '.type // empty')
    if [ "$layout" = "float" ]; then
        echo "true"
        return
    fi
    yabai -m query --windows --window 2>/dev/null | jq -r '."is-floating" // false'
}

toggle_zoom() {
    local is_floating
    is_floating=$(window_is_float)

    if [ "$is_floating" = "true" ]; then
        local cache_dir="/tmp/yabai/zoom_cache"
        mkdir -p "$cache_dir"
        local window_id
        window_id=$(yabai -m query --windows --window 2>/dev/null | jq -r '.id // empty')
        [ -z "$window_id" ] || [ "$window_id" = "null" ] && return 0

        local cache_file="$cache_dir/$window_id"
        if [ -f "$cache_file" ]; then
            read -r x y w h < "$cache_file"
            yabai -m window --resize "abs:$w:$h"
            yabai -m window --move "abs:$x:$y"
            rm -f "$cache_file"
        else
            yabai -m query --windows --window | jq -r '.frame.x, .frame.y, .frame.w, .frame.h' | tr '\n' ' ' > "$cache_file"
            yabai -m window --grid 1:1:0:0:1:1
        fi
    else
        yabai -m window --toggle zoom-fullscreen
    fi
}

toggle_zoom
