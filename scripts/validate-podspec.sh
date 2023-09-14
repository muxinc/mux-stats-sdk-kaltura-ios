#!/bin/bash
set -euo pipefail

readonly XCODE=$(xcodebuild -version | grep Xcode | cut -d " " -f2)

echo "▸ Current Xcode: $(xcode-select --print-path)"

echo "▸ Using Xcode Version: ${XCODE}"

echo "▸ Validating Podspec"

pod lib lint --verbose
