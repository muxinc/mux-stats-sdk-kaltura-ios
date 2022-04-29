BUILD_DIR=$PWD/MUXSDKKaltura/xc
PROJECT=$PWD/MUXSDKKaltura/MUXSDKKaltura.xcworkspace
TARGET_DIR=$PWD/XCFramework


# Delete the old stuff
rm -Rf $TARGET_DIR

# Make the build directory
mkdir -p $BUILD_DIR
# Make the target directory
mkdir -p $TARGET_DIR

# Clean up on error
clean_up_error () {
    rm -Rf $BUILD_DIR
    exit 1
}

# Build and clean up on error
build () {
  scheme=$1
  destination="$2"
  path="$3"
  
  xcodebuild archive -scheme $scheme -workspace $PROJECT -destination "$destination" -archivePath "$path" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES || clean_up_error
}

################ Build MUXSDKKaltura  

build MUXSDKKalturaTv "generic/platform=tvOS" "$BUILD_DIR/MUXSDKKalturaTv.tvOS.xcarchive"
build MUXSDKKalturaTv "generic/platform=tvOS Simulator" "$BUILD_DIR/MUXSDKKalturaTv.tvOS-simulator.xcarchive"
build MUXSDKKaltura "generic/platform=iOS" "$BUILD_DIR/MUXSDKKaltura.iOS.xcarchive"
build MUXSDKKaltura "generic/platform=iOS Simulator" "$BUILD_DIR/MUXSDKKaltura.iOS-simulator.xcarchive"
build MUXSDKKaltura "generic/platform=macOS,variant=Mac Catalyst" "$BUILD_DIR/MUXSDKKaltura.macOS.xcarchive"
  
 xcodebuild -create-xcframework -framework "$BUILD_DIR/MUXSDKKalturaTv.tvOS.xcarchive/Products/Library/Frameworks/MUXSDKKaltura.framework" \
                                -framework "$BUILD_DIR/MUXSDKKalturaTv.tvOS-simulator.xcarchive/Products/Library/Frameworks/MUXSDKKaltura.framework" \
                                -framework "$BUILD_DIR/MUXSDKKaltura.iOS.xcarchive/Products/Library/Frameworks/MUXSDKKaltura.framework" \
                                -framework "$BUILD_DIR/MUXSDKKaltura.iOS-simulator.xcarchive/Products/Library/Frameworks/MUXSDKKaltura.framework" \
                                -framework "$BUILD_DIR/MUXSDKKaltura.macOS.xcarchive/Products/Library/Frameworks/MUXSDKKaltura.framework" \
                                -output "$TARGET_DIR/MUXSDKKaltura.xcframework" || clean_up_error

rm -Rf $BUILD_DIR
