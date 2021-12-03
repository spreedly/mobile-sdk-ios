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
    s.platform         = :ios, '12.0'
    s.requires_arc     = true
    s.pod_target_xcconfig = { 'BITCODE_GENERATION_MODE' => 'bitcode' }

    s.license = { :type => 'Copyright', :text => $copyright }
    s.vendored_frameworks = 'Spreedly.xcframework'
end
