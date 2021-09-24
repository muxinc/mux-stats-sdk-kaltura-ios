#!/bin/bash
set -euo pipefail

cd MUXSDKKaltura
pod repo update
pod deintegrate && pod install
cd ..
PROJECT=MUXSDKKaltura/MUXSDKKaltura.xcworkspace

xcodebuild clean test \
  -workspace $PROJECT \
  -scheme MUXSDKKaltura \
  -destination 'platform=iOS Simulator,name=iPhone 11,OS=14.1' \
