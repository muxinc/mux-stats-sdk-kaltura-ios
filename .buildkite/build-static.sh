#!/bin/bash
set -euo pipefail

cd MUXSDKKaltura
pod repo update
pod deintegrate && pod install
cd ..
./update-release-xcframeworks-static.sh
zip -ry MUXSDKKaltura-static.xcframework.zip XCFramework
