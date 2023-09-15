#!/bin/bash
set -euo pipefail

readonly XCODE=$(xcodebuild -version | grep Xcode | cut -d " " -f2)
readonly SCHEME="mux-stats-sdk-kaltura-ios"

export LANG=en_US.UTF-8

echo "▸ Using Xcode Version: ${XCODE}"

echo "▸ Available Xcode SDKs"

xcodebuild -showsdks

echo "▸ xcodebuild clean test -scheme "mux-stats-sdk-kaltura-ios" -sdk iphonesimulator16.4 -destination 'name=iPhone 14,OS=16.4'"

xcodebuild clean test \
  -scheme "mux-stats-sdk-kaltura-ios" \
  -sdk iphonesimulator16.4 \
  -destination 'name=iPhone 14,OS=16.4' | xcbeautify
