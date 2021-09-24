BUILD_DIR=$PWD/MUXSDKKaltura/xc
PROJECT=$PWD/MUXSDKKaltura/MUXSDKKaltura.xcworkspace
TARGET_DIR=$PWD/XCFramework


# Delete the old stuff
rm -Rf $TARGET_DIR

# Make the build directory
mkdir -p $BUILD_DIR
# Make the target directory
mkdir -p $TARGET_DIR

################ Build MuxCore SDK

xcodebuild archive -scheme MUXSDKKalturaTv -workspace $PROJECT -destination "generic/platform=tvOS" -archivePath "$BUILD_DIR/MUXSDKKalturaTv.tvOS.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
 xcodebuild archive -scheme MUXSDKKalturaTv -workspace $PROJECT -destination "generic/platform=tvOS Simulator" -archivePath "$BUILD_DIR/MUXSDKKalturaTv.tvOS-simulator.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
 xcodebuild archive -scheme MUXSDKKaltura -workspace $PROJECT  -destination "generic/platform=iOS" -archivePath "$BUILD_DIR/MUXSDKKaltura.iOS.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
 xcodebuild archive -scheme MUXSDKKaltura -workspace $PROJECT  -destination "generic/platform=iOS Simulator" -archivePath "$BUILD_DIR/MUXSDKKaltura.iOS-simulator.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
 
  xcodebuild archive -scheme MUXSDKKaltura -workspace $PROJECT  -destination "generic/platform=macOS,variant=Mac Catalyst" -archivePath "$BUILD_DIR/MUXSDKKaltura.macOS.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
  
 xcodebuild -create-xcframework -framework "$BUILD_DIR/MUXSDKKalturaTv.tvOS.xcarchive/Products/Library/Frameworks/MUXSDKKaltura.framework" \
                                -framework "$BUILD_DIR/MUXSDKKalturaTv.tvOS-simulator.xcarchive/Products/Library/Frameworks/MUXSDKKaltura.framework" \
                                -framework "$BUILD_DIR/MUXSDKKaltura.iOS.xcarchive/Products/Library/Frameworks/MUXSDKKaltura.framework" \
                                -framework "$BUILD_DIR/MUXSDKKaltura.iOS-simulator.xcarchive/Products/Library/Frameworks/MUXSDKKaltura.framework" \
                                -framework "$BUILD_DIR/MUXSDKKaltura.macOS.xcarchive/Products/Library/Frameworks/MUXSDKKaltura.framework" \
                                -output "$TARGET_DIR/MUXSDKKaltura.xcframework"

rm -Rf $BUILD_DIR
