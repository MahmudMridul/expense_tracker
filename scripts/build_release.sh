#!/usr/bin/env bash
# Builds a size-optimized release APK per ABI (split, R8-shrunk,
# obfuscated). See README.md for what each flag buys.
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

fvm flutter pub get

fvm flutter build apk \
  --release \
  --split-per-abi \
  --obfuscate \
  --split-debug-info=build/symbols

echo
echo "Built APKs:"
ls -lh build/app/outputs/flutter-apk/*.apk
echo
echo "For a phone, install app-arm64-v8a-release.apk (covers virtually all"
echo "Android devices from the last several years):"
echo "  adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
