Pod::Spec.new do |s|
  s.name = 'LlamaMobileVD'
  s.version = '1.0.0'
  s.summary = 'Llama Mobile Vector Database Capacitor Plugin'
  s.description = 'High-performance vector storage and similarity search on iOS devices'
  s.license = 'MIT'
  s.homepage = 'https://github.com/your-org/llama_mobile_vector_database'
  s.author = 'LlamaMobileVD Team'
  s.source = { :git => 'https://github.com/your-org/llama_mobile_vector_database.git', :tag => s.version.to_s }
  s.ios.deployment_target = '14.0'
  s.swift_version = '5.0'
  
  s.source_files = 'ios/Plugin/**/*.{swift,h,m}'
  s.frameworks = 'Foundation', 'Accelerate'
  
  s.vendored_frameworks = 'ios/llama_mobile_vd.xcframework'
  
  s.dependency 'Capacitor'
end
