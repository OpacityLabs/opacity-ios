//
//  ViewController.m
//  test_app
//
//  Created by Oscar Franco on 20.08.24.
//

#import "ViewController.h"
#import "opacity.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)copyDocumentDirectory:(UITapGestureRecognizer *)gesture {
  NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(
      NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  [pasteboard setString:documentDirectory];
  NSLog(@"Document Directory copied to pasteboard: %@", documentDirectory);
}

- (void)getUberProfile {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        const char *profileChar = opacity_core::get_rider_profile();
        NSString *profile = [NSString stringWithUTF8String:profileChar];
        NSLog(@"Uber Profile: %@", profile);
        dispatch_async(dispatch_get_main_queue(), ^{
          NSArray *paths = NSSearchPathForDirectoriesInDomains(
              NSDocumentDirectory, NSUserDomainMask, YES);
          NSString *documentsDirectory = [paths objectAtIndex:0];
          NSString *filePath = [documentsDirectory
              stringByAppendingPathComponent:@"profile.json"];

          NSError *error;
          [profile writeToFile:filePath
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:&error];

          if (error) {
            NSLog(@"Error writing profile JSON to file: %@", error);
          } else {
            NSLog(@"Profile JSON written to file: %@", filePath);
          }
        });
      });
}

- (void)getUberRiderTripHistory {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        const char *historyChar = opacity_core::get_rider_trip_history(20, 0);
        NSString *history = [NSString stringWithUTF8String:historyChar];
        NSLog(@"Uber rider history: %@", history);
      });
}

- (void)getUberRiderTrip {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                 ^{
                   const char *tripChar = opacity_core::get_rider_trip(
                       "c7427573-0ea5-46a9-a9c5-e286efc31ff5");
                   NSString *trip = [NSString stringWithUTF8String:tripChar];
                   NSLog(@"Uber rider trip: %@", trip);
                 });
}

- (void)getUberDriverProfile {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        const char *profileChar = opacity_core::get_driver_profile();
        NSString *profile = [NSString stringWithUTF8String:profileChar];
        NSLog(@"Uber driver profile: %@", profile);
      });
}

- (void)viewDidLoad {
  [super viewDidLoad];

  UIButton *uberProfileButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [uberProfileButton setTitle:@"uber profile" forState:UIControlStateNormal];
  [uberProfileButton addTarget:self
                        action:@selector(getUberProfile)
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
  [uberDriverProfileButton setTitle:@"uber driver profile"
                           forState:UIControlStateNormal];
  [uberDriverProfileButton addTarget:self
                              action:@selector(getUberDriverProfile)
                    forControlEvents:UIControlEventTouchUpInside];
  uberDriverProfileButton.frame = CGRectMake(100, 450, 200, 50);
  [self.view addSubview:uberDriverProfileButton];

  UILabel *documentDirLabel =
      [[UILabel alloc] initWithFrame:CGRectMake(100, 500, 200, 50)];
  documentDirLabel.text =
      [NSString stringWithFormat:@"Document Directory: %@",
                                 [NSSearchPathForDirectoriesInDomains(
                                     NSDocumentDirectory, NSUserDomainMask, YES)
                                     firstObject]];
  documentDirLabel.userInteractionEnabled = YES;
  documentDirLabel.numberOfLines = 0;
  [documentDirLabel sizeToFit];
  [self.view addSubview:documentDirLabel];

  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(copyDocumentDirectory:)];
  [documentDirLabel addGestureRecognizer:tapGesture];
}

@end
