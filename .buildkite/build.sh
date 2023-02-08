#!/bin/bash
set -euo pipefail

export LANG=en_US.UTF-8

cd MUXSDKKaltura
pod repo update
pod deintegrate && pod install
cd ..
./update-release-xcframeworks.sh
zip -ry MUXSDKKaltura.xcframework.zip XCFramework
