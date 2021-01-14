Pod::Spec.new do |s|
    s.name             = "Spreedly3DS2"
    s.version          = $version
    s.summary          = "Spreedly 3DS2 support"
    s.description      = <<-DESC
                            The Spreedly iOS SDK makes it easy for you to accept a users credit card details inside your iOS app.
                            By creating payment method tokens, Spreedly handles the majority of your PCI compliance issues by
                            preventing sensitive credit card data from ever hitting your servers. Support for accpeting
                            3DS2 challenges.
                            DESC
    s.homepage         = "https://docs.spreedly.com/guides/mobile/ios/"
    s.authors          = { "Spreedly" => "support@spreedly.com" }
    s.source           = { :git => $repo, :tag => $tag }
    s.swift_version    = '5.0'
    s.platform         = :ios, '12.2'
    s.requires_arc     = true

    s.license = { :type => 'Copyright', :text => $copyright }
    s.vendored_frameworks = 'Spreedly3DS2.framework'
    s.public_header_files = "Spreedly3DS2.framework/Headers/*.h"
    s.source_files = "Spreedly3DS2.framework/Headers/*.h"
    s.user_target_xcconfig = {
          'SWIFT_INCLUDE_PATHS' => '"\$(PODS_ROOT)/Spreedly3DS2/Spreedly3DS2.framework"'
        }

end

