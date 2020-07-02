.PHONY: test coverage bundle

test:
	xcodebuild test -workspace SpreedlySdk.xcworkspace -scheme Spreedly -destination 'name=iPhone 11' -enableCodeCoverage YES

coverage: bundle test
	bundle exec slather coverage --html --scheme Spreedly --workspace SpreedlySdk.xcworkspace --output-directory slather-html SpreedlySdk.xcodeproj

# Install dependencies for test coverage
bundle:
	bundle install
