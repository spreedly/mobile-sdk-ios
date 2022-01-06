# DO NOT EDIT
# Edit the version in podspecs or version.podspec
$version = '1.0.0-beta10'
$repo = 'https://github.com/spreedly/mobile-sdk-ios.git'
$tag = "version_#{$version}"
$copyright = <<-LICENSE
Copyright 2020-2021, Spreedly Inc.
LICENSE
Pod::Spec.new do |s|
    s.name             = "Spreedly"
    s.version          = $version
    s.summary          = "Spreedly iOS SDK"
    s.description      = <<-DESC
                                The Spreedly iOS SDK makes it easy for you to accept a users credit card details inside your iOS app.
                                By creating payment method tokens, Spreedly handles the majority of your PCI compliance issues by
                                preventing sensitive credit card data from ever hitting your servers.
                                DESC
    s.homepage         = "https://docs.spreedly.com/guides/mobile/ios/"
    s.authors          = { "Spreedly" => "support@spreedly.com" }
    s.source           = { :git => $repo, :tag => $tag }
    s.swift_version    = '5.0'
    s.platform         = :ios, '12.2'
    s.requires_arc     = true

    s.license = { :type => 'Copyright', :text => $copyright }
    s.vendored_frameworks = 'Spreedly.xcframework'
end
