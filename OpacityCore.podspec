
Pod::Spec.new do |s|
  s.name             = 'OpacityCore'
  s.version          = '6.1.5'
  s.summary          = 'Core of Opacity'
  s.description      = 'Core library of Opacity Network for iOS'
  s.homepage         = 'https://github.com/OpacityLabs/opacity-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ospfranco' => 'ospfranco@gmail.com' }
  s.source           = { :git => 'https://github.com/OpacityLabs/opacity-ios.git', :tag => s.version.to_s }

  s.swift_version = '5.9'
  s.ios.deployment_target = '14.0'
  s.public_header_files = 'include/**/*.h', 'src/objc/*.h'
  s.source_files = 'src/**/*', 'include/**/*.h'
  
  s.vendored_frameworks = 'sdk.xcframework'
  s.frameworks = "WebKit", "CoreTelephony", "CoreLocation", "SystemConfiguration"

  # Configure for dynamic library
  s.pod_target_xcconfig = {
    'OTHER_LDFLAGS' => '-undefined dynamic_lookup'
  }
end
