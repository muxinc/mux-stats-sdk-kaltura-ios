#!/bin/bash
set -euo pipefail

cd MUXSDKKaltura
pod repo update
pod deintegrate && pod install
cd ..
./update-release-xcframeworks.sh
zip -ry MUXSDKKaltura.xcframework.zip XCFramework
