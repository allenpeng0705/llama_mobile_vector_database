# LlamaMobileVD Flutter Plugin Podspec
Pod::Spec.new do |s|
  s.name             = 'llama_mobile_vd'
  s.version          = '0.0.1'
  s.summary          = 'A high-performance vector database for Flutter applications'
  s.description      = <<-DESC
A Flutter plugin that provides access to the LlamaMobileVD vector database functionality.
                       DESC
  s.homepage         = 'https://github.com/your-username/llama_mobile_vd'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'your@email.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64 arm64'
  }
  s.swift_version = '5.0'
  
  # Add the LlamaMobileVD framework as a dependency
  s.vendored_frameworks = 'LlamaMobileVD.framework'
  
  # Add any additional frameworks or libraries needed
  s.libraries = 'c++'
end
