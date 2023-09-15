#!/bin/bash
set -euo pipefail

export LANG=en_US.UTF-8

xcodebuild -showsdks

xcodebuild clean test \
  -scheme "mux-stats-sdk-kaltura-ios" \
  -sdk iphonesimulator16.4 \
  -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.4' | xcbeautify
