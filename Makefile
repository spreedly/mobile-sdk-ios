.PHONY: test coverage bundle eli swiftdoc-install swiftdoc-generate swiftdoc-server push-spreedly-pod push-spreedlycocoa-pod lint

pod_version:= ${shell ruby -e 'load "version.podspec"; print($$version)'}
pod_tag:= ${shell ruby -e 'load "version.podspec"; print($$tag)'}
git_branch:= ${shell git rev-parse --abbrev-ref HEAD}
git_tag:= ${shell git tag -l --points-at HEAD}
git_commit_id:= ${shell git rev-parse HEAD}

assert-xcodebuild:
	(xcodebuild -version | grep 'Xcode 13') || { echo 'use Xcode 13 (found ${`xcodebuild -version`})'; exit 2; }
	-mkdir build

test: assert-xcodebuild
	xcodebuild test -workspace SpreedlySdk.xcworkspace -scheme Spreedly -destination 'name=iPhone 11' -enableCodeCoverage YES

coverage: bundle test
	bundle exec slather coverage --html --scheme Spreedly --workspace SpreedlySdk.xcworkspace --output-directory slather-html SpreedlySdk.xcodeproj

# Install dependencies for test coverage
bundle:
	bundle install

swiftdoc-install:
	@if ! command -v swift-doc &> /dev/null; then brew install swiftdocorg/formulae/swift-doc; fi

# The base url used by swift-doc to reference the css file.
baseurl ?= "/"

swiftdoc-generate: swiftdoc-install
	swift-doc generate ./Spreedly ./SpreedlyCocoa --module-name SpreedlyCocoa --module-name Spreedly --format html --output docs/html --base-url $(baseurl)
	swift-doc generate ./Spreedly ./SpreedlyCocoa --module-name SpreedlyCocoa --module-name Spreedly --format commonmark --output docs/md --base-url /reference/ios

swiftdoc-server: swiftdoc-generate
	pushd docs/html; python3 -m http.server; popd

private-pod-repo:
	-pod repo remove spreedly --silent
	pod repo add spreedly https://github.com/spreedly/mobile-sdk-ios.git podspecs_repo

push-spreedly-pod: private-pod-repo
	echo '# DO NOT EDIT\n# Edit the version in podspecs or version.podspec' > Spreedly.podspec
	cat version.podspec >> Spreedly.podspec
	cat podspecs/Spreedly.podspec >> Spreedly.podspec
	pod repo push spreedly Spreedly.podspec --verbose

push-spreedlycocoa-pod: private-pod-repo
	echo '# DO NOT EDIT\n# Edit the version in podspecs or version.podspec' > SpreedlyCocoa.podspec
	cat version.podspec >> SpreedlyCocoa.podspec
	cat podspecs/SpreedlyCocoa.podspec >> SpreedlyCocoa.podspec
	pod repo push spreedly SpreedlyCocoa.podspec --verbose

push-pods: push-spreedly-pod push-spreedlycocoa-pod

lint:
	./Pods/SwiftLint/swiftlint --config .swiftlint.yml

version-file:
	echo '// DO NOT EDIT/n// Edit the version in version.podspec\n\nimport Foundation\n\nclass SpreedlyVersion {\n    static let podVersion = "${pod_version}"\n    static let gitBranch = "${git_branch}";\n    static let gitTag = "${git_tag}";\n    static let gitCommitId = "${git_commit_id}";\n}\n' > Spreedly/SpreedlyVersion.swift

libs-simulator: assert-xcodebuild version-file
	xcodebuild BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS="-fembed-bitcode"  clean build -workspace SpreedlySdk.xcworkspace -scheme Frameworks -configuration Release -sdk iphonesimulator -derivedDataPath derived_data
	cd build; rm -rf simulator
	mkdir -p build/simulator
	cp -a derived_data/Build/Products/Release-iphonesimulator/. build/simulator

libs-simulator-debug: assert-xcodebuild version-file
	xcodebuild clean build -workspace SpreedlySdk.xcworkspace -scheme Frameworks -configuration Debug -sdk iphonesimulator -derivedDataPath derived_data
	cd build; rm -rf simulator-debug
	mkdir -p build/simulator-debug
	cp -a derived_data/Build/Products/Debug-iphonesimulator/. build/simulator-debug

libs-phone: assert-xcodebuild version-file
	xcodebuild BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS="-fembed-bitcode"  clean build -workspace SpreedlySdk.xcworkspace -scheme Frameworks -configuration Release -sdk iphoneos -derivedDataPath derived_data
	cd build; rm -rf iphone
	mkdir -p build/iphone
	cp -a derived_data/Build/Products/Release-iphoneos/. build/iphone

libs-phone-debug: assert-xcodebuild version-file
	xcodebuild clean build -workspace SpreedlySdk.xcworkspace -scheme Frameworks -configuration Debug -sdk iphoneos -derivedDataPath derived_data
	cd build; rm -rf iphone-debug
	mkdir -p build/iphone-debug
	cp -a derived_data/Build/Products/Debug-iphoneos/. build/iphone-debug

libs: libs-simulator-debug libs-phone-debug libs-simulator libs-phone
	cd build; rm -rf universal
	mkdir -p build/universal
	xcodebuild -create-xcframework -framework build/iphone/Spreedly.framework -framework build/simulator-debug/Spreedly.framework -output build/universal/Spreedly.xcframework
	xcodebuild -create-xcframework -framework build/iphone/SpreedlyCocoa.framework -framework build/simulator-debug/SpreedlyCocoa.framework -output build/universal/SpreedlyCocoa.xcframework
	xcodebuild -create-xcframework -framework build/iphone/Spreedly.framework -framework build/simulator/Spreedly.framework -output build/universal/Spreedly-Release.xcframework
	xcodebuild -create-xcframework -framework build/iphone/SpreedlyCocoa.framework -framework build/simulator/SpreedlyCocoa.framework -output build/universal/SpreedlyCocoa-Release.xcframework
	xcodebuild -create-xcframework -framework build/iphone-debug/Spreedly.framework -framework build/simulator-debug/Spreedly.framework -output build/universal/Spreedly-Debug.xcframework
	xcodebuild -create-xcframework -framework build/iphone-debug/SpreedlyCocoa.framework -framework build/simulator-debug/SpreedlyCocoa.framework -output build/universal/SpreedlyCocoa-Debug.xcframework
# 	for lib in $(shell cd build/universal; find . | grep '\([a-zA-Z0-9]*\)\.framework/\1$$') ; do \
# 		lipo -create build/simulator/$$lib build/iphone/$$lib -output build/universal/$$lib ;\
# 	doneccccccvkrtetigfdvrkebucgbgjcirincicvfedetfkh


push-frameworks: libs
	cd build; rm -rf pods
	git clone https://github.com/spreedly/mobile-sdk-ios.git --branch frameworks build/pods
	cd build/pods; rm -rf Spreedly.framework Spreedly3DS2.framework SpreedlyCocoa.framework Spreedly.xcframework Spreedly3DS2.xcframework SpreedlyCocoa.xcframework
	cp -a build/universal/*.xcframework build/pods
	cp podspecs/Package.swift.template build/pods/Package.swift
	cd build/pods; git add .; git commit -m 'version $(pod_version)'; git tag --force -a $(pod_tag) -m 'version $(pod_version)'
	cd build/pods; git push; git push --tags --force

