#!/usr/bin/env bash
# Hardware modifier key remappings for macOS
# 
# 1. Logitech Keyboard (ERGO K860 - VendorID 0x46d):
#    - ctrl -> cmd
#    - opt  -> ctrl
#    - cmd  -> opt
#
# 2. MacBook Internal Keyboard (VendorID 0x5ac, ProductID 0x342):
#    - fn   -> cmd
#    - ctrl -> ctrl (identity)
#    - opt  -> globe (fn)
#    - cmd  -> opt

# Logitech ERGO K860: ctrl -> cmd, opt -> ctrl, cmd -> opt
LOGI_MAPPING='{"UserKeyMapping":[
  {"HIDKeyboardModifierMappingSrc":30064771296,"HIDKeyboardModifierMappingDst":30064771299},
  {"HIDKeyboardModifierMappingSrc":30064771300,"HIDKeyboardModifierMappingDst":30064771303},
  {"HIDKeyboardModifierMappingSrc":30064771298,"HIDKeyboardModifierMappingDst":30064771296},
  {"HIDKeyboardModifierMappingSrc":30064771302,"HIDKeyboardModifierMappingDst":30064771300},
  {"HIDKeyboardModifierMappingSrc":30064771299,"HIDKeyboardModifierMappingDst":30064771298},
  {"HIDKeyboardModifierMappingSrc":30064771303,"HIDKeyboardModifierMappingDst":30064771302}
]}'

# MacBook Internal: fn -> cmd, opt -> globe, cmd -> opt
MAC_MAPPING='{"UserKeyMapping":[
  {"HIDKeyboardModifierMappingSrc":280379760050179,"HIDKeyboardModifierMappingDst":30064771299},
  {"HIDKeyboardModifierMappingSrc":30064771298,"HIDKeyboardModifierMappingDst":280379760050179},
  {"HIDKeyboardModifierMappingSrc":30064771302,"HIDKeyboardModifierMappingDst":280379760050179},
  {"HIDKeyboardModifierMappingSrc":30064771299,"HIDKeyboardModifierMappingDst":30064771298},
  {"HIDKeyboardModifierMappingSrc":30064771303,"HIDKeyboardModifierMappingDst":30064771302}
]}'

# Clear global mapping so device-specific rules take effect
/usr/bin/hidutil property --set '{"UserKeyMapping":[]}' > /dev/null 2>&1 || true

# Apply Logitech mapping
/usr/bin/hidutil property --matching '{"VendorID":0x46d}' --set "$LOGI_MAPPING" > /dev/null 2>&1 || true

# Apply MacBook internal keyboard mapping
/usr/bin/hidutil property --matching '{"ProductID":0x342,"VendorID":0x5ac}' --set "$MAC_MAPPING" > /dev/null 2>&1 || true
