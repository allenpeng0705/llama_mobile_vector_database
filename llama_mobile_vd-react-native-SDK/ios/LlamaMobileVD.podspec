Pod::Spec.new do |s|
  s.name         = "LlamaMobileVD"
  s.version      = "0.0.1"
  s.summary      = "A high-performance vector database for React Native applications using LlamaMobileVD"
  s.description  = "A high-performance vector database for React Native applications using LlamaMobileVD"
  s.homepage     = "https://github.com/allenpeng0705/llama_mobile/llama_mobile_vd-react-native-SDK"
  s.license      = "Apache-2.0"
  s.author       = { "Llama Mobile Team" => "team@llamamobile.com" }
  s.platform     = :ios, "13.0"
  s.source       = { :git => "https://github.com/allenpeng0705/llama_mobile/llama_mobile_vd-react-native-SDK.git", :tag => "#{s.version}" }
  s.source_files = "ios/**/*.{h,m,swift}"
  
  # React Native dependency
  s.dependency "React-Core"
  
  # Add the LlamaMobileVD framework dependency
  s.vendored_frameworks = "../ios/LlamaMobileVD.framework"
  
  # Other settings
  s.swift_versions = "5.0"
  s.static_framework = true
end