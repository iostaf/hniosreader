#!/usr/bin/env bash

## Configuration

JENKINS_DIRECTORY="$(pwd)/Jenkins"
BUILD_DIRECTORY="$JENKINS_DIRECTORY/build"
OBJ_DIRECTORY="$JENKINS_DIRECTORY/intermediate"
UNIT_TEST_DIRECTORY="$JENKINS_DIRECTORY/UnitTestResults"
CODE_ANALYSIS_DIRECTORY="$JENKINS_DIRECTORY/CodeAnalysis"
IPA_DIRECTORY="$JENKINS_DIRECTORY/ipa"


cleanup () {
    rm -rf $JENKINS_DIRECTORY
}

resolve () {
    pod install
}

run_tests () {
    mkdir -p "$BUILD_DIRECTORY"
    mkdir -p "$OBJ_DIRECTORY"
    mkdir -p "$UNIT_TEST_DIRECTORY"

    xctool -sdk iphonesimulator -workspace hn.xcworkspace -scheme hn -configuration 'Debug' OBJROOT=$OBJ_DIRECTORY clean
    xctool -sdk iphonesimulator -workspace hn.xcworkspace -scheme hn -configuration 'Debug' OBJROOT=$OBJ_DIRECTORY -reporter junit:$UNIT_TEST_DIRECTORY/unit-test-results.xml test -only hnTests
    gcovr -r . --object-directory "$OBJ_DIRECTORY/hn.build/Debug-iphonesimulator/hn.build/Objects-normal/i386" --exclude '.*Tests.*' --xml > coverage.xml
}

scan_build () {
    mkdir -p "$BUILD_DIRECTORY"
    mkdir -p "$CODE_ANALYSIS_DIRECTORY"

    scan-build -o $CODE_ANALYSIS_DIRECTORY xcodebuild -sdk iphoneos -workspace hn.xcworkspace -scheme hn -configuration 'Debug' CONFIGURATION_BUILD_DIR=$BUILD_DIRECTORY clean analyze
}

cleanup
resolve
run_tests
scan_build
