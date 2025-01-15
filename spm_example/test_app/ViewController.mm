#import "ViewController.h"
#import "OpacityObjCWrapper.h"

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
  [OpacityObjCWrapper get:@"flow:uber_rider:profile"
                andParams:nil
               completion:^(NSString *json, NSString *proof, NSError *error) {
                 if (error != NULL) {
                   NSLog(@"Error %@", error);
                 } else {
                   NSLog(@"Response %@", json);
                 }
               }];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  NSDictionary *env = [self loadEnvFile];
  NSString *api_key = env[@"OPACITY_API_KEY"];
  OpacityEnvironment environment = Production;
  [OpacityObjCWrapper initialize:api_key
                       andDryRun:false
                  andEnvironment:environment];

  UIButton *uberProfileButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [uberProfileButton setTitle:@"uber profile" forState:UIControlStateNormal];
  [uberProfileButton addTarget:self
                        action:@selector(getUberProfile)
              forControlEvents:UIControlEventTouchUpInside];
  uberProfileButton.frame = CGRectMake(100, 300, 200, 50);
  [self.view addSubview:uberProfileButton];
}

@end
