#
#  Be sure to run `pod spec lint CardKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "ThreeDSSDK"
  spec.version      = "0.0.17"
  spec.summary      = "CardKit SDK."
  spec.homepage     = "https://github.com/Runet-Business-Systems/CardKit"
  spec.license      = "MIT"
  spec.author       = { "RBS" => "rbssupport@bpc.ru" }
  spec.source       = { :git => "https://github.com/Runet-Business-Systems/CardKit.git" }
  spec.vendored_frameworks = 'CardKit/ThreeDSSDK.xcframework'
  spec.ios.deployment_target  = '10.0'
end
