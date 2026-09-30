#!/usr/bin/env bash
# Hardware modifier key remappings for macOS
# 
# 1. Logitech Keyboard (ERGO K860 - VendorID 0x46d, PrimaryUsagePage 1, PrimaryUsage 6):
#    - ctrl -> cmd
#    - opt  -> ctrl
#    - cmd  -> opt
#
# 2. MacBook Internal Keyboard (VendorID 0x5ac, ProductID 0x342, PrimaryUsagePage 1, PrimaryUsage 6):
#    - fn   -> cmd  (1095216660483 & 280379760050179 -> 30064771299)
#    - ctrl -> ctrl (identity)
#    - opt  -> globe/fn (30064771298 & 30064771302 -> 1095216660483)
#    - cmd  -> opt  (30064771299 -> 30064771298, 30064771303 -> 30064771302)

# Logitech ERGO K860: ctrl -> cmd, opt -> ctrl, cmd -> opt
LOGI_MAPPING='{"UserKeyMapping":[
  {"HIDKeyboardModifierMappingSrc":30064771296,"HIDKeyboardModifierMappingDst":30064771299},
  {"HIDKeyboardModifierMappingSrc":30064771300,"HIDKeyboardModifierMappingDst":30064771303},
  {"HIDKeyboardModifierMappingSrc":30064771298,"HIDKeyboardModifierMappingDst":30064771296},
  {"HIDKeyboardModifierMappingSrc":30064771302,"HIDKeyboardModifierMappingDst":30064771300},
  {"HIDKeyboardModifierMappingSrc":30064771299,"HIDKeyboardModifierMappingDst":30064771298},
  {"HIDKeyboardModifierMappingSrc":30064771303,"HIDKeyboardModifierMappingDst":30064771302}
]}'

# MacBook Internal: fn -> cmd, opt -> globe (fn), cmd -> opt
MAC_MAPPING='{"UserKeyMapping":[
  {"HIDKeyboardModifierMappingSrc":1095216660483,"HIDKeyboardModifierMappingDst":30064771299},
  {"HIDKeyboardModifierMappingSrc":280379760050179,"HIDKeyboardModifierMappingDst":30064771299},
  {"HIDKeyboardModifierMappingSrc":30064771298,"HIDKeyboardModifierMappingDst":1095216660483},
  {"HIDKeyboardModifierMappingSrc":30064771302,"HIDKeyboardModifierMappingDst":1095216660483},
  {"HIDKeyboardModifierMappingSrc":30064771299,"HIDKeyboardModifierMappingDst":30064771298},
  {"HIDKeyboardModifierMappingSrc":30064771303,"HIDKeyboardModifierMappingDst":30064771302}
]}'

# Clear global mapping so device-specific rules take effect
/usr/bin/hidutil property --set '{"UserKeyMapping":[]}' > /dev/null 2>&1 || true

# Clear internal TopCase management service so it does not double-map keystrokes before the keyboard driver
/usr/bin/hidutil property --matching '{"ProductID":0x342,"VendorID":0x5ac,"PrimaryUsagePage":65280}' --set '{"UserKeyMapping":[]}' > /dev/null 2>&1 || true

# Apply Logitech keyboard mapping (target keyboard usage specifically, not mouse)
/usr/bin/hidutil property --matching '{"VendorID":0x46d,"PrimaryUsagePage":1,"PrimaryUsage":6}' --set "$LOGI_MAPPING" > /dev/null 2>&1 || true

# Apply MacBook internal keyboard driver mapping (target keyboard usage specifically to prevent double mapping)
/usr/bin/hidutil property --matching '{"ProductID":0x342,"VendorID":0x5ac,"PrimaryUsagePage":1,"PrimaryUsage":6}' --set "$MAC_MAPPING" > /dev/null 2>&1 || true
