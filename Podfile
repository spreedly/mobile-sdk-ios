workspace 'SpreedlyWorkspace'
project 'Sdk/Sdk.xcodeproj'
project 'SdkCli/SdkCli.xcodeproj'

# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'


target 'Sdk' do
  use_frameworks!
  project 'Sdk/Sdk.xcodeproj'
  pod 'RxSwift', '~> 5.1.1'
  pod 'RxCocoa', '~> 5'
end

target 'SdkTests' do
  use_frameworks!
  project 'Sdk/Sdk.xcodeproj'
  pod 'RxTest', '~> 5'
  pod 'RxBlocking', '~> 5'
end

target 'SdkCli' do
  project 'SdkCli/SdkCli.xcodeproj'
  pod 'RxSwift', '~> 5.1.1'
  pod 'RxCocoa', '~> 5'
end
