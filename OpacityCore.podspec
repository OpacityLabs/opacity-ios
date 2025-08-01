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
  s.frameworks = "WebKit", "CoreTelephony", "CoreLocation", "SystemConfiguration"
  # s.preserve_paths = 'sdk.xcframework'
  s.vendored_frameworks = 'sdk.xcframework'
  # s.vendored_frameworks = 'sdk.xcframework/ios-arm64/sdk.framework'
  # s.vendored_frameworks = 'sdk.xcframework/ios-arm64_x86_64-simulator/sdk.framework'
  #   s.pod_target_xcconfig = {
  #   'OTHER_LDFLAGS' => '-undefined dynamic_lookup -Wl,-force_load,$(PODS_TARGET_SRCROOT)/sdk.xcframework/ios-arm64/sdk.framework/sdk'
  # }
  s.pod_target_xcconfig = {
    'OTHER_LDFLAGS' => '-undefined dynamic_lookup'
  }
  s.script_phase = {
    :name => 'Sign Framework Binary',
    :execution_position => :before_compile,
    :script => <<-SCRIPT
      echo "🟦🟦🟦🟦🟦🟦🟦 Framework Binary Signing Script ==="
      
      # Use BUILT_PRODUCTS_DIR which points to BuildProductsPath
      FRAMEWORK_DIR="${BUILT_PRODUCTS_DIR}/../XCFrameworkIntermediates/${PRODUCT_NAME}/sdk.framework"
      
      # Debug: Print the expected path
      echo "Looking for framework at: $FRAMEWORK_DIR"
      
      if [ -d "$FRAMEWORK_DIR" ]; then
        # Try different ways to get signing identity
        SIGN_IDENTITY="$EXPANDED_CODE_SIGN_IDENTITY"
        if [ -z "$SIGN_IDENTITY" ] || [ "$SIGN_IDENTITY" = "-" ]; then
          SIGN_IDENTITY="$CODE_SIGN_IDENTITY"
        fi
        if [ -z "$SIGN_IDENTITY" ] || [ "$SIGN_IDENTITY" = "-" ]; then
          # Use the first available distribution identity
          SIGN_IDENTITY=$(security find-identity -v -p codesigning | grep "Apple Distribution" | head -1 | awk '{print $2}')
        fi
        if [ -z "$SIGN_IDENTITY" ] || [ "$SIGN_IDENTITY" = "-" ]; then
          # Fallback to development identity
          SIGN_IDENTITY=$(security find-identity -v -p codesigning | grep "Apple Development" | head -1 | awk '{print $2}')
        fi

        if [ -z "$SIGN_IDENTITY" ] || [ "$SIGN_IDENTITY" = "-" ]; then
          echo "🟥🟥 No valid signing identity found"
          exit 1
        fi

        echo "Using identity: $SIGN_IDENTITY"
        
        codesign --force --sign "$SIGN_IDENTITY" "$FRAMEWORK_DIR"
        echo "🟩 Binary signed successfully"
      else
        echo "🟥 Framework not found at: $FRAMEWORK_DIR"
        exit 1
      fi
    SCRIPT
  }
  # s.script_phase = {
  #   :name => 'Sign Framework Binary',
  #   :execution_position => :before_compile,
  #   :script => <<-SCRIPT
  #     echo "=== Framework Binary Signing Script ==="
      
  #     # Find the framework path in the xcframework
  #     XCFRAMEWORK_PATH="${PODS_TARGET_SRCROOT}/sdk.xcframework"
  #     echo "XCFramework path: $XCFRAMEWORK_PATH"
      
  #     if [ -d "$XCFRAMEWORK_PATH" ]; then
  #       # Find the iOS framework within the xcframework
  #       FRAMEWORK_DIR=$(find "$XCFRAMEWORK_PATH" -name "*.framework" -type d | grep -E "(ios-arm64|ios)" | head -1)
        
  #       if [ -d "$FRAMEWORK_DIR" ]; then
  #         echo "Found framework: $FRAMEWORK_DIR"
          
  #         # Find the binary inside the framework (should be named 'sdk')
  #         BINARY_PATH="$FRAMEWORK_DIR/sdk"
          
  #         if [ -f "$BINARY_PATH" ]; then
  #           echo "Found binary: $BINARY_PATH"
            
  #           # Get signing identity - try different environment variables
  #           SIGN_IDENTITY="$EXPANDED_CODE_SIGN_IDENTITY"
  #           if [ -z "$SIGN_IDENTITY" ] || [ "$SIGN_IDENTITY" = "-" ]; then
  #             SIGN_IDENTITY="$CODE_SIGN_IDENTITY" 
  #           fi
  #           if [ -z "$SIGN_IDENTITY" ] || [ "$SIGN_IDENTITY" = "-" ]; then
  #             # Find available distribution identity - corrected sed pattern
  #             SIGN_IDENTITY=$(security find-identity -v -p codesigning | grep "Apple Distribution" | head -1 | sed 's/[[:space:]]*[0-9]*)[[:space:]]*\([A-F0-9]*\)[[:space:]].*/\1/')
  #           fi
  #           if [ -z "$SIGN_IDENTITY" ] || [ "$SIGN_IDENTITY" = "-" ]; then
  #             # Fallback to development identity - corrected sed pattern
  #             SIGN_IDENTITY=$(security find-identity -v -p codesigning | grep "Apple Development" | head -1 | sed 's/[[:space:]]*[0-9]*)[[:space:]]*\([A-F0-9]*\)[[:space:]].*/\1/')
  #           fi
            
  #           echo "Available identities:"
  #           security find-identity -v -p codesigning
  #           echo "Using signing identity: $SIGN_IDENTITY"
            
  #           if [ -n "$SIGN_IDENTITY" ] && [ "$SIGN_IDENTITY" != "-" ]; then
  #             echo "Signing binary with verbose output..."
  #             codesign --verbose=2 --force --sign "$SIGN_IDENTITY" "$BINARY_PATH"
              
  #             if [ $? -eq 0 ]; then
  #               echo "✓ Binary signed successfully"
                
  #               # Verify the signature
  #               echo "Verifying signature..."
  #               codesign --verify --verbose=2 "$BINARY_PATH"
  #             else
  #               echo "✗ Failed to sign binary"
  #               exit 1
  #             fi
  #           else
  #             echo "⚠️  No valid signing identity found"
  #           fi
  #         else
  #           echo "✗ Binary not found at: $BINARY_PATH"
  #         fi
  #       else
  #         echo "✗ No iOS framework found in xcframework"
  #       fi
  #     else
  #       echo "✗ XCFramework not found at: $XCFRAMEWORK_PATH"
  #     fi
      
  #     echo "=== Framework Binary Signing Complete ==="
  #   SCRIPT
  # }
end
