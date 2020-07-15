Pod::Spec.new do |s|
    s.name             = "SpreedlyCore"
    s.version          = "1.0.0"
    s.summary          = "Spreedly iOS SDK"
    s.description      = <<-DESC
                            The Spreedly iOS SDK makes it easy for you to accept a users credit card details inside your iOS app. By creating payment method tokens, Spreedly handles the majority of your PCI compliance issues by preventing sensitive credit card data from ever hitting your servers.
                            DESC
    s.homepage         = "https://docs.spreedly.com/guides/mobile/ios/"
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.authors          = { "Spreedly" => "support@spreedly.com" }
    s.source           = { :git => 'https://github.com/ergonlabs/spreedly-ios.git', :tag => 'podspec_${s.version}' }
    s.swift_version    = '5.0'

    s.platform         = :ios, '10.3'
    s.requires_arc     = true

    s.source_files     = 'Spreedly/**/*.swift', 'Spreedly/**/*.{m,h}'

    s.dependency 'RxSwift', '~> 5'
    s.dependency 'RxCocoa', '~> 5'
end
