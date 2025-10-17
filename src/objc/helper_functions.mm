#import "helper_functions.h"
#import "ModalWebViewController.h"
#import "Reachability.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <string>

ModalWebViewController *modalWebVC;
NSMutableURLRequest *request;
UINavigationController *navController;
NSString *userAgent;

UIViewController *topMostViewController() {
  // Fetch the key window's root view controller
  UIWindow *keyWindow = [UIApplication sharedApplication].windows.firstObject;
  UIViewController *topController = keyWindow.rootViewController;

  // Traverse the presented view controllers to find the topmost one
  while (topController.presentedViewController) {
    topController = topController.presentedViewController;
  }

  return topController;
}

void ios_prepare_request(const char *url) {
  NSString *urlString = [NSString stringWithUTF8String:url];
  request =
      [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
}

void ios_set_request_header(const char *key, const char *value) {
  NSString *nsKey = [NSString stringWithUTF8String:key];
  if ([nsKey caseInsensitiveCompare:@"User-Agent"] == NSOrderedSame) {
    userAgent = [NSString stringWithUTF8String:value];
  }
  NSString *nsValue = [NSString stringWithUTF8String:value];
  [request setValue:nsValue forHTTPHeaderField:nsKey];
}

void ios_close_webview() {
  dispatch_async(dispatch_get_main_queue(), ^{
    userAgent = nil;
    [navController dismissViewControllerAnimated:YES completion:nil];
  });
}

void ios_present_webview() {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (modalWebVC != nil) {
      NSLog(@"Warning: Previous modal web view controller has not been "
            @"dismissed");
    }

    modalWebVC = [[ModalWebViewController alloc] initWithRequest:request
                                                       userAgent:userAgent];

    // Set an on dismiss callback
    modalWebVC.onDismissCallback = ^{
      modalWebVC = nil;
      navController = nil;
    };

    navController =
        [[UINavigationController alloc] initWithRootViewController:modalWebVC];

    UIViewController *topController = topMostViewController();

    [topController presentViewController:navController
                                animated:YES
                              completion:nil];
  });
}

const char *ios_get_browser_cookies_for_domain(const char *domain) {
  if (modalWebVC == nil) {
    return nullptr;
  }
  NSString *domainString = [NSString stringWithUTF8String:domain];
  NSDictionary *cookies = [modalWebVC getBrowserCookiesForDomain:domainString];

  // Convert the dictionary to JSON string
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:cookies
                                                     options:0
                                                       error:&error];
  if (!jsonData) {
    NSLog(@"Error serializing cookies to JSON: %@", error);
    return "";
  }

  // Convert JSON data to C string and return
  NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                               encoding:NSUTF8StringEncoding];
  return [jsonString UTF8String];
}

const char *ios_get_browser_cookies_for_current_url() {
  if (modalWebVC == nil) {
    return nullptr;
  }

  NSDictionary *cookies = [modalWebVC getBrowserCookiesForCurrentUrl];

  // Convert the dictionary to JSON string
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:cookies
                                                     options:0
                                                       error:&error];
  if (!jsonData) {
    NSLog(@"Error serializing cookies to JSON: %@", error);
    return "";
  }

  // Convert JSON data to C string and return
  NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                               encoding:NSUTF8StringEncoding];
  return [jsonString UTF8String];
}

double get_battery_level() {
  UIDevice *device = [UIDevice currentDevice];
  device.batteryMonitoringEnabled = YES;
  double batteryLevel = static_cast<double>(device.batteryLevel);
  return batteryLevel;
}

const char *get_battery_status() {
  UIDevice *device = [UIDevice currentDevice];
  device.batteryMonitoringEnabled = YES;
  UIDeviceBatteryState batteryState = device.batteryState;

  const char *status = "Unknown";
  switch (batteryState) {
  case UIDeviceBatteryStateUnknown:
    status = "Unknown";
    break;
  case UIDeviceBatteryStateUnplugged:
    status = "Unplugged";
    break;
  case UIDeviceBatteryStateCharging:
    status = "Charging";
    break;
  case UIDeviceBatteryStateFull:
    status = "Full";
    break;
  }

  return status;
}

const char *get_carrier_name() {
  CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
  NSDictionary<NSString *, CTCarrier *> *carriers =
      [networkInfo serviceSubscriberCellularProviders];
  CTCarrier *carrier = carriers.allValues.firstObject;
  NSString *carrierName = [carrier carrierName];
  const char *name = [carrierName UTF8String];
  return name;
}

const char *get_carrier_mcc() {
  CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
  NSDictionary<NSString *, CTCarrier *> *carriers =
      [networkInfo serviceSubscriberCellularProviders];
  CTCarrier *carrier = carriers.allValues.firstObject;
  NSString *mcc = [carrier mobileCountryCode];
  const char *mccCString = [mcc UTF8String];
  return mccCString;
}

const char *get_carrier_mnc() {
  CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
  NSDictionary<NSString *, CTCarrier *> *carriers =
      [networkInfo serviceSubscriberCellularProviders];
  CTCarrier *carrier = carriers.allValues.firstObject;
  NSString *mnc = [carrier mobileNetworkCode];
  const char *mncCString = [mnc UTF8String];
  return mncCString;
}

double get_course() {
  CLLocationManager *locationManager = [[CLLocationManager alloc] init];
  CLLocationDirection course = locationManager.heading.trueHeading;
  return course;
}

const char *get_cpu_abi() {
  const char *cpuAbi = "arm64-v8a";
  return cpuAbi;
}

double get_altitude() {
  CLLocationManager *locationManager = [[CLLocationManager alloc] init];

  CLLocation *location = locationManager.location;
  double altitude = location.altitude;
  return altitude;
}

double get_latitude() {
  CLLocationManager *locationManager = [[CLLocationManager alloc] init];

  CLLocation *location = locationManager.location;
  double latitude = location.coordinate.latitude;
  return latitude;
}

double get_longitude() {
  CLLocationManager *locationManager = [[CLLocationManager alloc] init];

  CLLocation *location = locationManager.location;
  double longitude = location.coordinate.longitude;
  return longitude;
}

const char *get_device_model() {
  NSString *deviceModel = [UIDevice currentDevice].model;
  const char *model = [deviceModel UTF8String];
  return model;
}

const char *get_os_name() {
  NSString *osName = [UIDevice currentDevice].systemName;
  const char *name = [osName UTF8String];
  return name;
}

const char *get_os_version() {
  NSString *osVersion = [UIDevice currentDevice].systemVersion;
  const char *version = [osVersion UTF8String];
  return version;
}

bool is_emulator() {
  bool isSimulator = false;

#if TARGET_IPHONE_SIMULATOR
  isSimulator = true;
#endif

  return isSimulator;
}

double get_horizontal_accuracy() {
  CLLocationManager *locationManager = [[CLLocationManager alloc] init];

  CLLocation *location = locationManager.location;
  double horizontalAccuracy = location.horizontalAccuracy;
  return horizontalAccuracy;
}

double get_vertical_accuracy() {
  CLLocationManager *locationManager = [[CLLocationManager alloc] init];

  CLLocation *location = locationManager.location;
  double verticalAccuracy = location.verticalAccuracy;
  return verticalAccuracy;
}

const char *get_ip_address() {
  struct ifaddrs *interfaces = NULL;
  struct ifaddrs *temp_addr = NULL;
  const char *ipAddress = "Unknown";

  // Retrieve the current interfaces - returns 0 on success
  if (getifaddrs(&interfaces) == 0) {
    // Loop through linked list of interfaces
    temp_addr = interfaces;
    while (temp_addr != NULL) {
      // Check if the interface is IPv4 or IPv6
      if (temp_addr->ifa_addr->sa_family == AF_INET) {
        // Check if the interface is not a loopback address
        if (strcmp(temp_addr->ifa_name, "lo0") != 0) {
          // Convert the IP address from a binary to a string representation
          ipAddress =
              inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr);
          break;
        }
      }
      temp_addr = temp_addr->ifa_next;
    }
  }

  // Free memory
  freeifaddrs(interfaces);

  return ipAddress;
}

bool is_location_services_enabled() {
  return CLLocationManager.locationServicesEnabled;
}

bool is_wifi_connected() {
  Reachability *reachability = [Reachability reachabilityForInternetConnection];
  NetworkStatus netStatus = [reachability currentReachabilityStatus];
  return netStatus == ReachableViaWiFi;
}

bool is_rooted() { return false; }

bool is_app_foregrounded() {
  UIApplicationState state = [[UIApplication sharedApplication] applicationState];
  return state == UIApplicationStateActive;
}
