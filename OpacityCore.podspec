
Pod::Spec.new do |s|
  s.name             = 'OpacityCore'
  s.version          = '3.11.23'
  s.summary          = 'Core of Opacity'
  s.description      = 'Core library of Opacity Network for iOS'
  s.homepage         = 'https://github.com/OpacityLabs/opacity-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ospfranco' => 'ospfranco@gmail.com' }
  s.source           = { :git => 'https://github.com/OpacityLabs/opacity-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17'
  }
  s.pod_target_xcconfig = { 'DEAD_CODE_STRIPPING' => 'YES' }
  s.source_files = 'Opacity/**/*'
  if File.exist?('opacity-debug.xcframework')
    s.vendored_frameworks = 'opacity-debug.xcframework'
  else
    s.vendored_frameworks = 'opacity.xcframework'
  end
  s.frameworks = "WebKit", "CoreTelephony", "CoreLocation", "SystemConfiguration"
end