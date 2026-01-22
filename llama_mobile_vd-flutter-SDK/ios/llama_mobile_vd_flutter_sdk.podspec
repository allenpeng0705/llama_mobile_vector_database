Pod::Spec.new do |s|
  s.name             = 'llama_mobile_vd_flutter_sdk'
  s.version          = '0.0.1'
  s.summary          = 'Flutter SDK for Llama Mobile Vector Database'
  s.description      = <<-DESC
Flutter SDK for Llama Mobile Vector Database
                       DESC
  s.homepage         = 'https://github.com/llama-mobile/llama_mobile_vd'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Llama Mobile' => 'contact@llama-mobile.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '5.0'

  # Add the framework
  s.vendored_frameworks = 'llama_mobile_vd.xcframework'
end
