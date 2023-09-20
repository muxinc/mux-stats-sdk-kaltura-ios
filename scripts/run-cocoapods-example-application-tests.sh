#!/bin/bash
set -euo pipefail

readonly XCODE=$(xcodebuild -version | grep Xcode | cut -d " " -f2)
readonly SCHEME=DemoApp
readonly WORKSPACE=DemoApp.xcworkspace

echo "▸ Using Xcode Version: ${XCODE}"

export LANG=en_US.UTF-8

echo "▸ Export LANG=${LANG}"

echo "▸ Reset Simulators"
xcrun -v simctl shutdown all
xcrun -v simctl erase all

cd apps/DemoApp

echo "▸ Reset Local Cocoapod Cache"
pod cache clean --all

echo "▸ Reset Cocoapod Installation"
pod deintegrate && pod install --clean-install

echo "▸ Run Application Tests"
xcodebuild clean test \
    -workspace $WORKSPACE \
    -scheme $SCHEME \
    -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.4' | xcbeautify
