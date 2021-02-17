# Spreedly SDK - iOS Frameworks

This is where the compiled frameworks are stored for use directly or with cocoapods.

# Release process

First you want to edit 'versions.podspec' and bump the version number.

Second you want to build and new frameworks. Run `make push-frameworks`

Third you want to push the latest podspec file. Run `make push-pods`

Then do the same in the 3ds2 repository.
