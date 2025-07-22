
Pod::Spec.new do |s|
  s.name             = 'OpacityCore'
  s.version          = '6.1.0'
  s.summary          = 'Core of Opacity'
  s.description      = 'Core library of Opacity Network for iOS'
  s.homepage         = 'https://github.com/OpacityLabs/opacity-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ospfranco' => 'ospfranco@gmail.com' }
  s.source           = { :git => 'https://github.com/OpacityLabs/opacity-ios.git', :tag => s.version.to_s }

  s.swift_version = '5.9'
  s.ios.deployment_target = '14.0'
  s.source_files = 'src/**/*'
  if File.exist?('opacity-debug.xcframework')
    s.vendored_frameworks = 'opacity-debug.xcframework'
  else
    s.vendored_frameworks = 'opacity.xcframework'
  end
  s.frameworks = "WebKit", "CoreTelephony", "CoreLocation", "SystemConfiguration"
end