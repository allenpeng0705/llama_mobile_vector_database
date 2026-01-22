require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "llama_mobile_vd-react-native-sdk"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = package["description"]
  s.homepage     = ""
  s.license      = package["license"]
  s.author       = package["author"]
  s.platform     = :ios, "12.0"
  s.source       = { :git => "", :tag => "#{s.version}" }
  
  s.source_files = "ios/**/*.{h,m,swift}"
  s.vendored_frameworks = "ios/llama_mobile_vd.xcframework"
  
  s.dependency "React-Core"
end
