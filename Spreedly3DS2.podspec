Pod::Spec.new do |s|
    s.name             = "Spreedly3DS2"
    s.version          = "1.0.0"
    s.summary          = "Spreedly 3DS2 support"
    s.description      = <<-DESC
                            The Spreedly iOS SDK makes it easy for you to accept a users credit card details inside your iOS app.
                            By creating payment method tokens, Spreedly handles the majority of your PCI compliance issues by
                            preventing sensitive credit card data from ever hitting your servers. Support for accpeting
                            3DS2 challenges.
                            DESC
    s.homepage         = "https://docs.spreedly.com/guides/mobile/ios/"
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.authors          = { "Spreedly" => "support@spreedly.com" }
    s.source           = { :git => 'https://github.com/ergonlabs/spreedly-ios.git', :tag => "podspec_#{s.version}" }
    s.swift_version    = '5.0'

    s.platform         = :ios, '12.2'
    s.requires_arc     = true

    s.source_files     = 'Spreedly3DS2/**/*.swift', 'SpreedlyCocoa/**/*.{m,h}'

    s.ios.resource_bundle = {
        'Spreedly3DS2Resources' => [
            'Spreedly3DS2/**/*.{json,png,xcassets,storyboard}',
            'Spreedly3DS2/*.lproj'
        ]
    }

    s.dependency 'Spreedly', '>= ' + s.version.to_s
end

