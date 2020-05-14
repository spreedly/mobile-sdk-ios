.PHONY: test coverage bundle

test:
	xcodebuild test -workspace SpreedlySdk.xcworkspace -scheme Sdk -destination 'name=iPhone 11' -enableCodeCoverage YES

coverage: test
	bundle exec slather coverage --html --scheme Sdk --workspace SpreedlySdk.xcworkspace --output-directory slather-html SpreedlySdk.xcodeproj

# Install dependencies for test coverage
bundle:
	bundle install --path vendor/bundle
