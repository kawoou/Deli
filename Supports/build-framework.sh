#!/bin/bash -e
set -o pipefail

erb Supports/Autowired.erb > Sources/Deli/Autowired.swift
erb Supports/Configuration.erb > Sources/Deli/Configuration.swift
erb Supports/LazyAutowired.erb > Sources/Deli/LazyAutowired.swift
erb Supports/AutowiredFactory.erb > Sources/Deli/AutowiredFactory.swift
erb Supports/LazyAutowiredFactory.erb > Sources/Deli/LazyAutowiredFactory.swift

./Binary/Build/deli build

swift package clean
swift package generate-xcodeproj

if [ $TEST == 1 ]; then
    xcodebuild clean build test \
        -project "Deli.xcodeproj" \
        -scheme "Deli-Package" \
        -destination "$DESTINATION" \
        -configuration Debug \
        -enableCodeCoverage YES \
        CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO | xcpretty -c

    bash <(curl -s https://codecov.io/bash) -X xcodeplist -J 'Deli'
else
    xcodebuild clean build \
        -project "Deli.xcodeproj" \
        -scheme "Deli-Package" \
        -destination "$DESTINATION" \
        -configuration Debug \
        CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO | xcpretty -c
fi
