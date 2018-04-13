#!/bin/bash -e
set -o pipefail

rm Sources/Deli/Autowired.swift
rm Sources/Deli/Configuration.swift
rm Sources/Deli/LazyAutowired.swift

erb Supports/Autowired.erb >> Sources/Deli/Autowired.swift
erb Supports/Configuration.erb >> Sources/Deli/Configuration.swift
erb Supports/LazyAutowired.erb >> Sources/Deli/LazyAutowired.swift

swift package clean
swift package generate-xcodeproj

xcodebuild clean build \
    -project "Deli.xcodeproj" \
    -scheme "Deli-Package" \
    -destination "$DESTINATION" \
    -configuration Debug \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO | xcpretty -c;

carthage build --no-skip-current --verbose | xcpretty -c
carthage archive Deli
