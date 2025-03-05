#import "OpacityObjCWrapper.h"
#import "opacity.h"

@implementation OpacityObjCWrapper

+ (int)initialize:(NSString *)api_key
                       andDryRun:(BOOL)dry_run
                  andEnvironment:(OpacityEnvironment)environment
    andShouldShowErrorsInWebview:(BOOL)should_show_errors_in_webview
                        andError:(NSError *__autoreleasing *)error {
  char *err;
  int status = opacity_core::init([api_key UTF8String], dry_run,
                                  static_cast<int>(environment),
                                  should_show_errors_in_webview, &err);
  if (status != opacity_core::OPACITY_OK) {
    NSString *errorMessage = [NSString stringWithUTF8String:err];
    *error =
        [NSError errorWithDomain:@"OpacitySDK"
                            code:status
                        userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
  }

  return status;
}

+ (void)get:(NSString *)name
     andParams:(NSDictionary *)params
    completion:(void (^)(NSDictionary *res, NSError *error))completion {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *res, *err;
        NSError *error;
        NSString *jsonString = nil;
        if (params) {
          NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                             options:0
                                                               error:&error];
          if (!jsonData) {
            completion(nil, error);
            return;
          }
          jsonString = [[NSString alloc] initWithData:jsonData
                                             encoding:NSUTF8StringEncoding];
        }

        int status = opacity_core::get(
            [name UTF8String], jsonString ? [jsonString UTF8String] : nullptr,
            &res, &err);

        if (status != opacity_core::OPACITY_OK) {
          NSString *errorMessage = [NSString stringWithUTF8String:err];
          NSError *error = [NSError
              errorWithDomain:@"com.opacity"
                         code:status
                     userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
          opacity_core::free_string(err);
          completion(nil, error);
          return;
        }

        NSString *final_res = [NSString stringWithUTF8String:res];
        opacity_core::free_string(res);
        NSData *data = [final_res dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError;
        NSDictionary *jsonDict =
            [NSJSONSerialization JSONObjectWithData:data
                                            options:0
                                              error:&jsonError];
        if (jsonError) {
          completion(nil, jsonError);
          return;
        }

        completion(jsonDict, nil);
      });
}

@end
