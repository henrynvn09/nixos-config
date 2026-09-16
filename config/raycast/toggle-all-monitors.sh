#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle All Monitors
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🖥️
# @raycast.argument1 { "type": "text", "placeholder": "toggle | off | on", "optional": true }

# Documentation:
# @raycast.author henry_nguyen
# @raycast.authorURL https://raycast.com/henry_nguyen
# @raycast.description Toggle brightness of all connected displays (built-in and external monitors) on and off.

export PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/usr/local/bin:/opt/homebrew/bin:$PATH"

ACTION="${1:-toggle}"
STATE_FILE="/tmp/all_monitors_brightness_state.json"
BD="/Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay"

/usr/bin/python3 - <<PYEOF
import json
import os
import subprocess
import sys

BD = "$BD"
STATE_FILE = "$STATE_FILE"
ACTION = "$ACTION"

def get_displays():
    if not os.path.exists(BD):
        return []
    try:
        out = subprocess.check_output([BD, "get", "-identifiers"], stderr=subprocess.DEVNULL).decode("utf-8").strip()
        if not out:
            return []
        displays = json.loads("[" + out + "]")
        return [d["displayID"] for d in displays if d.get("deviceType") == "Display"]
    except Exception:
        return []

def get_brightness(did):
    try:
        val = subprocess.check_output([BD, "get", f"-displayID={did}", "-brightness"], stderr=subprocess.DEVNULL).decode("utf-8").strip()
        return float(val)
    except Exception:
        return 0.0

def set_brightness(did, val):
    try:
        subprocess.run([BD, "set", f"-displayID={did}", f"-brightness={val}"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
    except Exception:
        pass
    # For main MacBook screen (display 1), also call native brightness CLI if available
    if str(did) == "1" and os.path.exists("/usr/local/bin/brightness"):
        try:
            subprocess.run(["/usr/local/bin/brightness", "-d", "1", str(val)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception:
            pass

display_ids = get_displays()

if not display_ids:
    # Fallback to /usr/local/bin/brightness if BetterDisplay is not available
    if os.path.exists("/usr/local/bin/brightness"):
        try:
            result = subprocess.check_output(["/usr/local/bin/brightness", "-l"], stderr=subprocess.DEVNULL).decode("utf-8")
            import re
            b_match = re.search(r"brightness\s+([0-9.]+)", result)
            cur_b = float(b_match.group(1)) if b_match else 0.8
            if cur_b == 0 or ACTION == "on":
                subprocess.run(["/usr/local/bin/brightness", "0.8"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                print("Main screen on (BetterDisplay not found)")
            else:
                subprocess.run(["/usr/local/bin/brightness", "0"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                print("Main screen off (BetterDisplay not found)")
        except Exception:
            print("Error: Could not adjust screen brightness")
    else:
        print("Error: Neither BetterDisplay nor brightness CLI found")
    sys.exit(0)

# Load saved state if present
saved_state = {}
if os.path.exists(STATE_FILE):
    try:
        with open(STATE_FILE, "r") as f:
            saved_state = json.load(f)
    except Exception:
        saved_state = {}

current_brightnesses = {}
any_on = False
for did in display_ids:
    b = get_brightness(did)
    current_brightnesses[str(did)] = b
    if b > 0.001:
        any_on = True

if ACTION == "off" or (ACTION == "toggle" and any_on):
    # Turn off all monitors
    # Save current brightness levels for any monitor that is currently > 0
    state_to_save = {}
    for did, b in current_brightnesses.items():
        if b > 0.001:
            state_to_save[did] = b
        elif str(did) in saved_state and saved_state[str(did)] > 0.001:
            state_to_save[did] = saved_state[str(did)]
        else:
            state_to_save[did] = 0.8
    try:
        with open(STATE_FILE, "w") as f:
            json.dump(state_to_save, f)
    except Exception:
        pass

    for did in display_ids:
        set_brightness(did, 0)

    print(f"All screens off ({len(display_ids)} displays)")

elif ACTION == "on" or (ACTION == "toggle" and not any_on):
    # Turn on all monitors
    for did in display_ids:
        target_b = saved_state.get(str(did), 0.8)
        if target_b <= 0.001:
            target_b = 0.8
        set_brightness(did, target_b)

    print(f"All screens on ({len(display_ids)} displays)")
PYEOF
