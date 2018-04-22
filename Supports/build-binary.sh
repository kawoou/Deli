#!/bin/bash -e
set -o pipefail

rm Binary/Sources/Deli/Model/Version.swift
erb version=`cat version` Supports/Version.erb >> Binary/Sources/Deli/Model/Version.swift

cd Binary/

rm -rf Build/
mkdir Build

swift package clean
swift package generate-xcodeproj

xcodebuild clean build \
    -project "Deli.xcodeproj" \
    -scheme "deli" \
    -destination "arch=x86_64" \
    -configuration Debug \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO | xcpretty -c;

swift build -c release
cp .build/release/deli ./Build
pkgbuild --identifier "io.kawoou.deli" --install-location "/usr/local/bin" --root "Build" --version "`cat ../version`" "Build/Deli.pkg"
cd Build
zip -yr - "deli" "../../LICENSE" > "portable_deli.zip"
cd ..

rm -rf Deli.xcodeproj/

cd ../
