.PHONY: test coverage bundle eli swiftdoc-generate

name ?= scott

test:
	xcodebuild test -workspace SpreedlySdk.xcworkspace -scheme Spreedly -destination 'name=iPhone 11' -enableCodeCoverage YES

coverage: bundle test
	bundle exec slather coverage --html --scheme Spreedly --workspace SpreedlySdk.xcworkspace --output-directory slather-html SpreedlySdk.xcodeproj

# Install dependencies for test coverage
bundle:
	bundle install

swiftdoc:
	git clone https://github.com/SwiftDocOrg/swift-doc swiftdoc\
    && cd swiftdoc \
    && make install prefix=.

swiftdoc-generate: swiftdoc
	./swiftdoc/bin/swift-doc generate ./Spreedly ./SpreedlyCocoa --module-name SpreedlyCocoa --format html
