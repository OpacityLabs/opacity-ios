Pod::Spec.new do |s|
  s.name             = 'OpacityCore'
  s.version          = '6.1.9'
  s.summary          = 'Core of Opacity'
  s.description      = 'Core library of Opacity Network for iOS'
  s.homepage         = 'https://github.com/OpacityLabs/opacity-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ospfranco' => 'ospfranco@gmail.com' }
  s.source           = { :git => 'https://github.com/OpacityLabs/opacity-ios.git', :tag => s.version.to_s }
  s.swift_version = '5.9'
  s.ios.deployment_target = '14.0'
  s.source_files = 'src/**/*'
  s.resource_bundles = {
    'OpacityCore' => ['exports.exp']
  }
  s.frameworks = "WebKit", "CoreTelephony", "CoreLocation", "SystemConfiguration"
  s.vendored_frameworks = 'sdk.xcframework'
  
  # Focus on user target - this is where the final linking happens
  s.user_target_xcconfig = {
    # 'OTHER_LDFLAGS' => '$(inherited) -Wl,-u,_ios_prepare_request -Wl,-u,_ios_set_request_header -Wl,-u,_ios_present_webview -Wl,-u,_ios_close_webview -Wl,-u,_ios_get_browser_cookies_for_current_url -Wl,-u,_ios_get_browser_cookies_for_domain -Wl,-u,_get_ip_address -Wl,-u,_is_rooted -Wl,-u,_is_wifi_connected -Wl,-u,_is_location_services_enabled -Wl,-u,_get_os_name -Wl,-u,_get_os_version -Wl,-u,_is_emulator -Wl,-u,_get_battery_level -Wl,-u,_get_battery_status -Wl,-u,_get_carrier_name -Wl,-u,_get_carrier_mcc -Wl,-u,_get_carrier_mnc -Wl,-u,_get_course -Wl,-u,_get_cpu_abi -Wl,-u,_get_altitude -Wl,-u,_get_latitude -Wl,-u,_get_longitude -Wl,-u,_get_device_model -Wl,-u,_get_horizontal_accuracy -Wl,-u,_get_vertical_accuracy',
    'STRIP_STYLE' => 'non-global'
    # 'KEEP_PRIVATE_EXTERNS' => 'YES'
  }
end
