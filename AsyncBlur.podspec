#
#  Be sure to run `pod spec lint AsyncBlur.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "AsyncBlur"
  s.version      = "0.2.1"
  s.summary      = "Renderring blurred image from UIImage in background with optimizations."
  s.description = <<-DESC
                  Allows developers render blurred images in background.
                  If you want your image view always be blurred, just use ABImageView instead of UIImageView.
                  DESC
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Vladislav Dugnist" => "vdugnist@gmail.com" }
  s.homepage = "https://github.com/ML-Works/AsyncBlur"
  s.source       = { :git => "https://github.com/ML-Works/AsyncBlur.git", :tag => "#{s.version}" }
  s.source_files  = "AsyncBlur", "AsyncBlur/AsyncBlur/**/*.{h,m}"
  s.platform = :ios, 8.0
  s.requires_arc = true

end

