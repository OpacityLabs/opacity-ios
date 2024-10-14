# Opacity iOS

Wrapper for the Opacity Core library for iOS. It's both a Cocoapod and SPM package

### Swift Package Manager:

- On Xcode go to `Menu Bar` → `file` → `Add package dependency`. Copy github repo url into the top right search field
  ```
  https://github.com/OpacityLabs/opacity-ios
  ```
- Be sure to select a stable version if necessary.

### Cocoapods

- Add `OpacityCore` into your Podfile
- You need to bump your minimum deployment target to iOS 14

## Swift

If you want to call the SDK functions from Swift, you need to create a bridging header if you don't have it already.

In the file explorer, right click and `create new file from template`, select Swift file, and create an empty file. Xcode should prompt you to create a Bridging Header, accept and add the following line:

```
#import "OpacityObjCWrapper.h"
```

Afterwards you should be able to import the Opacity Swift wrapper and call the functions natively.

```
import OpacitySwiftWrapper

...
OpacityCore.getUberRiderProfile()
```

## Usage

You have to dispatch the calls in another thread other than the main thread, as they might block your UI:

```swift
import OpacityCore

DispatchQueue.global(qos: .background).async {
    do {
      let (json, proof) = try OpacitySwiftWrapper.getUberRiderProfile()
      DispatchQueue.main.async {
        // Update UI or handle the result on the main thread if needed
      }
    } catch {
      DispatchQueue.main.async {
        print("Error: \(error)")
      }
    }
  }
```

```obj-c
#import "opacity.h"

dispatch_async(
  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    char *json;
    char *proof;
    char *err;

    int status = opacity_core::get_uber_rider_profile(&json, &proof, &err);

    if (status != opacity_core::OPACITY_OK) {
      NSString *errorMessage = [NSString stringWithUTF8String:err];
      NSLog(@"Error getting rider profile: %@", errorMessage);
      return;
    }

    NSString *profile = [NSString stringWithUTF8String:json];
    NSLog(@"Uber rider Profile: %@", profile);
  }
);
```

## License

This wrapper is MIT. However, the core library contained in opacity.xcframework is not.
