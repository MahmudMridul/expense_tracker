#!/usr/bin/env bash
# Starts the project's Android emulator (if not already running) and blocks
# until it has finished booting, so a debug launch can proceed straight to
# `flutter run` against it. Used as a VS Code preLaunchTask.
set -euo pipefail

AVD_NAME="medium_phone"
DEVICE_ID="emulator-5554"

if ! adb devices | grep -qE "^${DEVICE_ID}\s+device$"; then
  echo "Starting emulator '${AVD_NAME}'..."
  nohup android emulator start "${AVD_NAME}" >/tmp/expense_tracker_emulator.log 2>&1 &
  adb wait-for-device
fi

echo "Waiting for emulator to finish booting..."
until [ "$(adb -s "${DEVICE_ID}" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do
  sleep 2
done

echo "Emulator ready."
