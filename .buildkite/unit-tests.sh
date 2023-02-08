#!/bin/bash
set -euo pipefail

export LANG=en_US.UTF-8

cd MUXSDKKaltura
pod repo update
pod deintegrate && pod install
cd ..
PROJECT=MUXSDKKaltura/MUXSDKKaltura.xcworkspace

xcodebuild clean test \
  -workspace $PROJECT \
  -scheme MUXSDKKaltura \
  -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.2' \
