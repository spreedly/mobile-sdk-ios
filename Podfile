project 'SpreedlySdk.xcodeproj'

# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

pod 'SwiftLint'

target 'Spreedly' do
  use_frameworks!
  pod 'DLRadioButton', '~> 1.4'
end

target 'SpreedlyCocoa' do
  use_frameworks!
end

target 'CocoaSample' do
  use_frameworks!
end

target 'UnitTests' do
  use_frameworks!
end

target 'IntegrationTests' do
  use_frameworks!
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end