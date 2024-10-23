#import "OpacityViewController.h"
#import "Foundation/Foundation.h"
#import "opacity.h"
#import <CoreLocation/CoreLocation.h>
#import <string>

@interface OpacityViewController ()

@end

@implementation OpacityViewController

- (NSDictionary *)loadEnvFile {
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@".env"
                                                       ofType:nil];
  NSError *error;
  NSString *content = [NSString stringWithContentsOfFile:filePath
                                                encoding:NSUTF8StringEncoding
                                                   error:&error];

  if (error) {
    NSLog(@"Error reading .env file: %@", error.localizedDescription);
    return nil;
  }

  NSMutableDictionary *envVariables = [NSMutableDictionary dictionary];
  NSArray *lines = [content componentsSeparatedByString:@"\n"];

  for (NSString *line in lines) {
    if ([line containsString:@"="]) {
      NSArray *keyValuePair = [line componentsSeparatedByString:@"="];
      NSString *key = [keyValuePair[0]
          stringByTrimmingCharactersInSet:[NSCharacterSet
                                              whitespaceCharacterSet]];
      NSString *value = [keyValuePair[1]
          stringByTrimmingCharactersInSet:[NSCharacterSet
                                              whitespaceCharacterSet]];
      envVariables[key] = value;
    }
  }

  return [envVariables copy];
}

- (void)getRiderProfile {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json, *proof, *err;

        int status = opacity_core::get_uber_rider_profile(&json, &proof, &err);

        if (status != opacity_core::OPACITY_OK) {
          NSString *errorMessage = [NSString stringWithUTF8String:err];
          NSLog(@"Error getting rider profile: %@", errorMessage);
          return;
        }

        NSString *profile = [NSString stringWithUTF8String:json];
        NSLog(@"Uber rider Profile: %@", profile);
      });
}

- (void)getUberRiderTripHistory {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json;
        char *proof;
        char *err;

        const char status =
            opacity_core::get_uber_rider_trip_history(nil, &json, &proof, &err);
        if (status != opacity_core::OPACITY_OK) {
          NSString *errorMessage = [NSString stringWithUTF8String:err];
          NSLog(@"Error: %@", errorMessage);
          return;
        }

        NSString *data = [NSString stringWithUTF8String:json];
        NSLog(@"Uber rider trip history: %@", data);
      });
}

- (void)getUberRiderTrip {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json;
        char *proof;
        char *err;

        const char status = opacity_core::get_uber_rider_trip(
            "c7427573-0ea5-46a9-a9c5-e286efc31ff5", &json, &proof, &err);
        if (status != opacity_core::OPACITY_OK) {
          NSString *errorMessage = [NSString stringWithUTF8String:err];
          NSLog(@"Error: %@", errorMessage);
          return;
        }

        NSString *data = [NSString stringWithUTF8String:json];
        NSLog(@"data: %@", data);
      });
}

- (void)getUberDriverProfile {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json;
        char *proof;
        char *err;

        const char status =
            opacity_core::get_uber_driver_profile(&json, &proof, &err);
        if (status != opacity_core::OPACITY_OK) {
          NSString *errorMessage = [NSString stringWithUTF8String:err];
          NSLog(@"Error: %@", errorMessage);
          return;
        }

        NSString *data = [NSString stringWithUTF8String:json];
        NSLog(@" %@", data);
      });
}

- (void)getUberDriverTrips {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json;
        char *proof;
        char *err;

        const char status = opacity_core::get_uber_driver_trips(
            "2024-01-01", "2024-07-31", "", &json, &proof, &err);
        if (status != opacity_core::OPACITY_OK) {
          NSString *errorMessage = [NSString stringWithUTF8String:err];
          NSLog(@"Error: %@", errorMessage);
          return;
        }

        NSString *data = [NSString stringWithUTF8String:json];
        NSLog(@" %@", data);
      });
}

- (void)getRedditProfile {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json;
        char *proof;
        char *err;

        const char status =
            opacity_core::get_reddit_account(&json, &proof, &err);
        if (status != opacity_core::OPACITY_OK) {
          NSString *errorMessage = [NSString stringWithUTF8String:err];
          NSLog(@"Error: %@", errorMessage);
          return;
        }

        NSString *data = [NSString stringWithUTF8String:json];
        NSLog(@" %@", data);
      });
}

- (void)getZabkaProfile {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json;
        char *proof;
        char *err;

        const char status =
            opacity_core::get_zabka_account(&json, &proof, &err);
        if (status != opacity_core::OPACITY_OK) {
          NSString *errorMessage = [NSString stringWithUTF8String:err];
          NSLog(@"Error: %@", errorMessage);
          return;
        }

        NSString *data = [NSString stringWithUTF8String:json];
        NSLog(@" %@", data);
      });
}

- (void)viewDidLoad {
  [super viewDidLoad];

  NSDictionary *env = [self loadEnvFile];
  NSString *api_key = env[@"OPACITY_API_KEY"];

  auto status = opacity_core::init([api_key UTF8String], false);

  if (status != opacity_core::OPACITY_OK) {
    NSLog(@"Error initializing Opacity SDK");
    return;
  }

  // Request location permissions
  CLLocationManager *locationManager = [[CLLocationManager alloc] init];
  [locationManager requestWhenInUseAuthorization];

  UIButton *uberProfileButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [uberProfileButton setTitle:@"Uber get rider profile"
                     forState:UIControlStateNormal];
  [uberProfileButton addTarget:self
                        action:@selector(getRiderProfile)
              forControlEvents:UIControlEventTouchUpInside];
  uberProfileButton.frame = CGRectMake(100, 300, 200, 50);
  [self.view addSubview:uberProfileButton];

  UIButton *uberRiderHistoryButton =
      [UIButton buttonWithType:UIButtonTypeSystem];
  [uberRiderHistoryButton setTitle:@"uber rider trip history"
                          forState:UIControlStateNormal];
  [uberRiderHistoryButton addTarget:self
                             action:@selector(getUberRiderTripHistory)
                   forControlEvents:UIControlEventTouchUpInside];
  uberRiderHistoryButton.frame = CGRectMake(100, 350, 200, 50);
  [self.view addSubview:uberRiderHistoryButton];

  UIButton *uberTripButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [uberTripButton setTitle:@"uber rider trip" forState:UIControlStateNormal];
  [uberTripButton addTarget:self
                     action:@selector(getUberRiderTrip)
           forControlEvents:UIControlEventTouchUpInside];
  uberTripButton.frame = CGRectMake(100, 400, 200, 50);
  [self.view addSubview:uberTripButton];

  UIButton *uberDriverProfileButton =
      [UIButton buttonWithType:UIButtonTypeSystem];
  [uberDriverProfileButton setTitle:@"GET Uber driver profile"
                           forState:UIControlStateNormal];
  [uberDriverProfileButton addTarget:self
                              action:@selector(getUberDriverProfile)
                    forControlEvents:UIControlEventTouchUpInside];
  uberDriverProfileButton.frame = CGRectMake(100, 450, 200, 50);
  [self.view addSubview:uberDriverProfileButton];

  UIButton *uberDriverTripsButton =
      [UIButton buttonWithType:UIButtonTypeSystem];
  [uberDriverTripsButton setTitle:@"uber driver trips"
                         forState:UIControlStateNormal];
  [uberDriverTripsButton addTarget:self
                            action:@selector(getUberDriverTrips)
                  forControlEvents:UIControlEventTouchUpInside];
  uberDriverTripsButton.frame = CGRectMake(100, 500, 200, 50);
  [self.view addSubview:uberDriverTripsButton];

  UIButton *zabkaProfileButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [zabkaProfileButton setTitle:@"zabka Profile" forState:UIControlStateNormal];
  [zabkaProfileButton addTarget:self
                         action:@selector(getZabkaProfile)
               forControlEvents:UIControlEventTouchUpInside];
  zabkaProfileButton.frame = CGRectMake(100, 550, 200, 50);
  [self.view addSubview:zabkaProfileButton];

  UIButton *getRedditAccountButton =
      [UIButton buttonWithType:UIButtonTypeSystem];
  [getRedditAccountButton setTitle:@"reddit account"
                          forState:UIControlStateNormal];
  [getRedditAccountButton addTarget:self
                             action:@selector(getRedditProfile)
                   forControlEvents:UIControlEventTouchUpInside];
  getRedditAccountButton.frame = CGRectMake(100, 600, 200, 50);
  [self.view addSubview:getRedditAccountButton];
}

@end
