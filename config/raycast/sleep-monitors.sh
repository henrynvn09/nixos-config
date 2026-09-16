#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Sleep All Displays
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌙

# Documentation:
# @raycast.author henry_nguyen
# @raycast.authorURL https://raycast.com/henry_nguyen
# @raycast.description Immediately put all connected monitors into display sleep (wakes on keypress or mouse movement).

pmset displaysleepnow
