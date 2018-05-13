#!/bin/bash -e
set -o pipefail

rm Binary/Sources/Deli/Model/Version.swift
erb version=`cat version` Supports/Version.erb >> Binary/Sources/Deli/Model/Version.swift

cd Binary/

rm -rf .build/
rm -rf Build/
mkdir Build

swift build -c release -Xswiftc -static-stdlib
cp .build/release/deli ./Build
pkgbuild --identifier "io.kawoou.deli" --install-location "/usr/local/bin" --root "Build" --version "`cat ../version`" "Build/Deli.pkg"
cp ../LICENSE ./Build/LICENSE
cd Build
zip -yr - "deli" "LICENSE" > "portable_deli.zip"
cd ../..
