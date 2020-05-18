#!/usr/bin/env bash

pushd CoreSdk
../Pods/SwiftLint/swiftlint
popd
pushd SdkTests
../Pods/SwiftLint/swiftlint
popd
pushd SdkIntegraionTests
../Pods/SwiftLint/swiftlint
popd
pushd Sample
../Pods/SwiftLint/swiftlint
popd

