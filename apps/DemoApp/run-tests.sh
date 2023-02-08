#!/bin/bash
set -euo pipefail

export LANG=en_US.UTF-8

# Delete the old stuff
rm -Rf XCFramework
# reset simulators
xcrun -v simctl shutdown all
xcrun -v simctl erase all
buildkite-agent artifact download "MUXSDKKaltura.xcframework.zip" . --step ".buildkite/build.sh"
unzip MUXSDKKaltura.xcframework.zip
cd apps/DemoApp
pod deintegrate && pod update
xcodebuild -workspace DemoApp.xcworkspace \
           -scheme "DemoApp" \
           -destination 'platform=iOS Simulator,name=iPhone 11,OS=14.1' \
           test
