.PHONY: test coverage bundle eli swiftdoc-install swiftdoc-generate swiftdoc-server push-spreedly-pod push-spreedlycocoa-pod lint

assert-xcodebuild:
	(xcodebuild -version | grep 'Xcode 11.7') || { echo 'use Xcode 11.7'; exit 2; }

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

push-spreedly-pod:
	pod repo push spreedly-spec-demo Spreedly.podspec --verbose

push-spreedlycocoa-pod:
	pod repo push spreedly-spec-demo SpreedlyCocoa.podspec --verbose

push-spreedly3ds2-pod:
	pod repo push spreedly-spec-demo Spreedly3DS2.podspec --verbose

push-pods: push-spreedly-pod push-spreedlycocoa-pod push-spreedly3ds2-pod

lint:
	./Pods/SwiftLint/swiftlint --config .swiftlint.yml

libs-simulator: assert-xcodebuild
	xcodebuild clean build -workspace SpreedlySdk.xcworkspace -scheme Frameworks -configuration Release -sdk iphonesimulator -derivedDataPath derived_data
	mkdir -p build/simulator
	cp -a derived_data/Build/Products/Release-iphonesimulator/. build/simulator

libs: assert-xcodebuild
	xcodebuild clean build -workspace SpreedlySdk.xcworkspace -scheme Frameworks -configuration Release -sdk iphoneos -derivedDataPath derived_data
	mkdir -p build/iphone
	cp -a derived_data/Build/Products/Release-iphoneos/. build/iphone

libs-merged: libs-simulator libs
	mkdir -p build/universal
	cp -a build/iphone/. build/universal
	for lib in $(shell cd build/universal; find . | grep '\([a-zA-Z0-9]*\)\.framework/\1$$') ; do \
		lipo -create build/simulator/$$lib build/iphone/$$lib -output build/universal/$$lib ;\
	done


