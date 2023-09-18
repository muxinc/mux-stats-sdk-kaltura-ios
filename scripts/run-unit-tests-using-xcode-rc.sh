#!/bin/bash
set -euo pipefail

export LANG=en_US.UTF-8

echo "▸ Current Xcode: $(xcode-select -p)"

echo "▸ Available Xcode SDKs"

xcodebuild -showsdks

echo "▸ Testing SDK on iOS 17.0"

xcodebuild clean test \
  -scheme "mux-stats-sdk-kaltura-ios" \
  -sdk iphonesimulator17.0 \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' | xcbeautify

echo "▸ Testing SDK on tvOS 17.0"

xcodebuild clean test \
  -scheme "mux-stats-sdk-kaltura-ios" \
  -sdk appletvsimulator17.0 \
  -destination 'platform=tvOS Simulator,name=Apple TV,OS=17.0' | xcbeautify
