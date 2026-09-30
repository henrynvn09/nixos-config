#!/usr/bin/env bash
# Hardware modifier key remapping for macOS
# Caps Lock -> Cmd, Fn -> Cmd, Cmd -> Opt, Opt -> Disabled
# Applies to internal MacBook keyboard and external keyboards (e.g. Logitech ERGO K860)

MAPPING_JSON='{"UserKeyMapping":[
  {"HIDKeyboardModifierMappingSrc":30064771300,"HIDKeyboardModifierMappingDst":30064771300},
  {"HIDKeyboardModifierMappingSrc":280379760050179,"HIDKeyboardModifierMappingDst":30064771299},
  {"HIDKeyboardModifierMappingSrc":30064771302,"HIDKeyboardModifierMappingDst":30064771072},
  {"HIDKeyboardModifierMappingSrc":1095216660483,"HIDKeyboardModifierMappingDst":30064771303},
  {"HIDKeyboardModifierMappingSrc":30064771129,"HIDKeyboardModifierMappingDst":30064771303},
  {"HIDKeyboardModifierMappingSrc":30064771298,"HIDKeyboardModifierMappingDst":30064771072},
  {"HIDKeyboardModifierMappingSrc":30064771299,"HIDKeyboardModifierMappingDst":30064771298},
  {"HIDKeyboardModifierMappingSrc":30064771296,"HIDKeyboardModifierMappingDst":30064771296},
  {"HIDKeyboardModifierMappingSrc":30064771303,"HIDKeyboardModifierMappingDst":30064771302}
]}'

# 1. Apply globally to all connected keyboards
/usr/bin/hidutil property --set "$MAPPING_JSON" > /dev/null 2>&1 || true

# 2. Specifically ensure internal MacBook keyboard is mapped
/usr/bin/hidutil property --matching '{"ProductID":0x342,"VendorID":0x5ac}' --set "$MAPPING_JSON" > /dev/null 2>&1 || true
