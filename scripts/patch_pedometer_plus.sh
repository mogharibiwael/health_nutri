#!/bin/bash
# Fix pedometer_plus Android namespace for AGP compatibility.
# Run after: flutter pub get
# Usage: ./scripts/patch_pedometer_plus.sh

PEDO_FILE="$HOME/.pub-cache/hosted/pub.dev/pedometer_plus-1.0.1/android/build.gradle"
if [ -f "$PEDO_FILE" ]; then
  if ! grep -q "namespace 'com.example.pedometer'" "$PEDO_FILE"; then
    # macOS-compatible sed
    sed -i '' "s/^android {/android {\n    namespace 'com.example.pedometer'/1" "$PEDO_FILE"
    echo "Patched pedometer_plus build.gradle"
  else
    echo "pedometer_plus already patched"
  fi
else
  echo "pedometer_plus not found. Run: flutter pub get first"
fi
