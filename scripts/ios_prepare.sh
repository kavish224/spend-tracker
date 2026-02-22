#!/bin/sh
# Run this before opening Xcode so that ios/Flutter/Generated.xcconfig exists.
# Usage: from project root: sh scripts/ios_prepare.sh

set -e
cd "$(dirname "$0")/.."
echo "Running flutter pub get..."
flutter pub get
echo "Running pod install..."
cd ios && pod install && cd ..
echo "Done. You can open ios/Runner.xcworkspace in Xcode now."
