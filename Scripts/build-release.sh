#!/usr/bin/env bash

## Configuration

JENKINS_DIRECTORY="$(pwd)/Jenkins"
BUILD_DIRECTORY="$JENKINS_DIRECTORY/build"
IPA_DIRECTORY="$JENKINS_DIRECTORY/ipa"


cleanup () {
    rm -rf $JENKINS_DIRECTORY
}

resolve () {
    pod install
}

build () {
    mkdir -p $BUILD_DIRECTORY
    xcodebuild -sdk iphoneos -workspace hn.xcworkspace -scheme hn -configuration 'Release' CONFIGURATION_BUILD_DIR=$BUILD_DIRECTORY clean build
}

package () {
    cd "$BUILD_DIRECTORY" || die "Build directory does not exist."
    mkdir -p $IPA_DIRECTORY
    for APP_FILENAME in *.app; do
        APP_NAME=$(echo "$APP_FILENAME" | sed -e 's/.app//')
        IPA_FILENAME="$APP_NAME.ipa"
        DSYM_FILEPATH="$APP_FILENAME.dSYM"
        xcrun -sdk iphoneos PackageApplication -v "$APP_FILENAME" -o "$IPA_DIRECTORY/$IPA_FILENAME"
        tar czf "$IPA_DIRECTORY/$DSYM_FILEPATH.tar" "$DSYM_FILEPATH"
    done
}

cleanup
resolve
build
package
