#!/bin/bash
set -euo pipefail

export LANG=en_US.UTF-8

pod spec lint

cd MUXSDKKaltura
rm -rf Podfile.lock
pod cache clean --all
pod repo update
pod deintegrate && pod install --clean-install --repo-update
cd ..
PROJECT=MUXSDKKaltura/MUXSDKKaltura.xcworkspace

xcodebuild clean test \
  -workspace $PROJECT \
  -scheme MUXSDKKaltura \
  -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.4' | xcbeautify
