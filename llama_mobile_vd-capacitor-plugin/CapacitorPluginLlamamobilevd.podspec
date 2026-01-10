Pod::Spec.new do |s|
  s.name = 'CapacitorPluginLlamamobilevd'
  s.version = '0.0.1'
  s.summary = 'A high-performance vector database for mobile applications using LlamaMobileVD'
  s.license = 'Apache-2.0'
  s.homepage = 'https://github.com/allenpeng0705/llama_mobile/llama_mobile_vd-capacitor-plugin'
  s.author = 'Llama Mobile Team'
  s.source = { :git => 'https://github.com/allenpeng0705/llama_mobile/llama_mobile_vd-capacitor-plugin.git', :tag => s.version.to_s }
  s.source_files = 'ios/Sources/**/*.{swift,h,m,c,cc,mm,cpp}'
  s.dependency 'Capacitor'
  
  # Add the LlamaMobileVD framework dependency
  s.vendored_frameworks = 'ios/LlamaMobileVD.framework'
  
  s.ios.deployment_target  = '13.0'
  s.static_framework = true
end