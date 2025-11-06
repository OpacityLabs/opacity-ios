Pod::Spec.new do |s|
  s.name             = 'OpacityCore'
  s.version          = '6.8.0'
  s.summary          = 'Core of Opacity'
  s.description      = 'Core library of Opacity Network for iOS'
  s.homepage         = 'https://github.com/OpacityLabs/opacity-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ospfranco' => 'ospfranco@gmail.com' }
  s.source           = { :git => 'https://github.com/OpacityLabs/opacity-ios.git', :tag => s.version.to_s }
  s.swift_version = '5.9'
  s.ios.deployment_target = '14.0'
  s.source_files = 'src/**/*'
  s.frameworks = "WebKit", "CoreTelephony", "CoreLocation", "SystemConfiguration"
  s.vendored_frameworks = 'sdk.xcframework'
  # We do not actually care about the dynamic lookup but if this is not here
  # then cocoapods fails with missing implementation for the dylib functions.
  s.pod_target_xcconfig = {
    "OTHER_LDFLAGS" => '-undefined dynamic_lookup',
  }
end
