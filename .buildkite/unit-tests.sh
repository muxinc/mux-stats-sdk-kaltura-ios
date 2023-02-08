#!/bin/bash
set -euo pipefail

#cd MUXSDKKaltura
#pod repo update
#pod deintegrate && pod install
#cd ..
PROJECT=MUXSDKKaltura/MUXSDKKaltura.xcworkspace

echo " PRINTING WORKING DIR ------------"
pwd

xcodebuild clean test \
  -workspace $PROJECT \
  -scheme MUXSDKKaltura \
  -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.2' \
