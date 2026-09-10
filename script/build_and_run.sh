#!/usr/bin/env bash
set -euo pipefail

MODE="run"
if [[ $# -gt 0 ]]; then MODE="$1"; fi
case "$MODE" in
  run|--debug|--logs|--telemetry|--verify|--build) ;;
  *) echo "Usage: $0 [--debug|--logs|--telemetry|--verify|--build]" >&2; exit 2 ;;
esac

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="TextreamPersonal"
BUNDLE_ID="dev.osmanartuner.textream.personal"
BUILD_DIR="$ROOT_DIR/.build/personal"
APP_BUNDLE="$HOME/Applications/$APP_NAME.app"

if pgrep -x "$APP_NAME" >/dev/null; then
  osascript -e "tell application id \"$BUNDLE_ID\" to quit"
  for attempt in {1..30}; do
    if ! pgrep -x "$APP_NAME" >/dev/null; then break; fi
    sleep 0.1
  done
  if pgrep -x "$APP_NAME" >/dev/null; then
    echo "Stop the active prompter and close Textream Personal before rebuilding." >&2
    exit 1
  fi
fi

mkdir -p "$BUILD_DIR" "$HOME/Applications"
if ! xcodebuild \
  -project "$ROOT_DIR/Textream/Textream.xcodeproj" \
  -scheme Textream -configuration Release \
  -destination "platform=macOS,arch=$(uname -m)" \
  -derivedDataPath "$BUILD_DIR" \
  build > "$BUILD_DIR/build.log" 2>&1; then
  tail -80 "$BUILD_DIR/build.log" >&2
  exit 1
fi

if [[ -e "$APP_BUNDLE" ]]; then
  EXISTING_ID=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$APP_BUNDLE/Contents/Info.plist")
  if [[ "$EXISTING_ID" != "$BUNDLE_ID" ]]; then
    echo "Another application already occupies $APP_BUNDLE." >&2
    exit 1
  fi
  rm -rf "$APP_BUNDLE"
fi
ditto "$BUILD_DIR/Build/Products/Release/$APP_NAME.app" "$APP_BUNDLE"
codesign --verify --strict "$APP_BUNDLE"
echo "Built and installed: $APP_BUNDLE"

case "$MODE" in
  --build) ;;
  --debug) lldb -- "$APP_BUNDLE/Contents/MacOS/$APP_NAME" ;;
  --logs)
    open -n "$APP_BUNDLE"
    /usr/bin/log stream --info --style compact --predicate "process == \"$APP_NAME\""
    ;;
  --telemetry)
    open -n "$APP_BUNDLE"
    /usr/bin/log stream --info --style compact --predicate "subsystem == \"$BUNDLE_ID\""
    ;;
  --verify)
    open -n "$APP_BUNDLE"
    sleep 1
    pgrep -x "$APP_NAME" >/dev/null
    echo "Launch verified."
    ;;
  run) open -n "$APP_BUNDLE" ;;
esac
