#import "ViewController.h"
#import "opacity.h"

@interface ViewController ()

@end

@implementation ViewController

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

- (void)getUberProfile {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json;
        char *proof;
        char *err;
        int status = opacity_core::get_uber_rider_profile(&json, &proof, &err);
        if (status == opacity_core::OPACITY_OK) {
          NSString *data = [NSString stringWithUTF8String:json];
          NSLog(@" %@", data);
        }
      });
}

- (void)viewDidLoad {
  [super viewDidLoad];
  NSDictionary *env = [self loadEnvFile];
  NSString *api_key = env[@"OPACITY_API_KEY"];

  opacity_core::init([api_key UTF8String], false);

  UIButton *uberProfileButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [uberProfileButton setTitle:@"uber profile" forState:UIControlStateNormal];
  [uberProfileButton addTarget:self
                        action:@selector(getUberProfile)
              forControlEvents:UIControlEventTouchUpInside];
  uberProfileButton.frame = CGRectMake(100, 300, 200, 50);
  [self.view addSubview:uberProfileButton];
}

@end
