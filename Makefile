.PHONY: test coverage bundle eli swiftdoc-install swiftdoc-generate swiftdoc-server push-spreedly-pod push-spreedlycocoa-pod lint

test:
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
	swift-doc generate ./Spreedly ./SpreedlyCocoa --module-name SpreedlyCocoa --module-name Spreedly --format html --base-url $(baseurl)

swiftdoc-server: swiftdoc-generate
	pushd .build/documentation; python3 -m http.server; popd

push-spreedly-pod:
	pod repo push spreedly-spec-demo Spreedly.podspec --verbose

push-spreedlycocoa-pod:
	pod repo push spreedly-spec-demo SpreedlyCocoa.podspec --verbose

lint:
	./Pods/SwiftLint/swiftlint --config .swiftlint.yml
