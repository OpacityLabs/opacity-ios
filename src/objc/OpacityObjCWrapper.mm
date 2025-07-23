#import "OpacityObjCWrapper.h"
#import "OpacityIOSHelper.h"
#import "opacity.h"
#import <dlfcn.h>

NSError *parseOpacityError(NSString *jsonString) {
  NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
  NSError *parsingError;
  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                       options:0
                                                         error:&parsingError];
  if (parsingError != nil) {
    return [NSError errorWithDomain:@"OpacitySDKUnkownError"
                               code:1001
                           userInfo:@{NSLocalizedDescriptionKey : jsonString}];
    ;
  }

  NSString *code = json[@"code"];
  NSString *desc = json[@"description"];
  // We are not using this field for now
  // NSString *translation = json[@"translation_key"];

  return [NSError errorWithDomain:code
                             code:1001
                         userInfo:@{NSLocalizedDescriptionKey : desc}];
}

@implementation OpacityObjCWrapper

+ (int)initialize:(NSString *)api_key
                       andDryRun:(BOOL)dry_run
                  andEnvironment:(OpacityEnvironment)environment
    andShouldShowErrorsInWebview:(BOOL)should_show_errors_in_webview
                        andError:(NSError *__autoreleasing *)error {

  opacity::force_symbol_registration();

  // First, load the main executable to make its symbols available
  void *main_handle = dlopen(NULL, RTLD_NOW | RTLD_GLOBAL);
  if (!main_handle) {
    NSString *errorMessage = [NSString stringWithUTF8String:dlerror()];
    *error =
        [NSError errorWithDomain:@"OpacitySDKMainError"
                            code:1003
                        userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
    return -1;
  }

  NSBundle *dylib_bundle =
      [NSBundle bundleWithIdentifier:@"com.opacitylabs.sdk"];
  NSString *dylib_path = [dylib_bundle pathForResource:@"sdk" ofType:@""];

  // Load the dynamic library
  void *handle = dlopen([dylib_path UTF8String], RTLD_NOW | RTLD_GLOBAL);
  if (!handle) {
    NSString *errorMessage = [NSString stringWithUTF8String:dlerror()];
    *error =
        [NSError errorWithDomain:@"OpacitySDKDylibError"
                            code:1002
                        userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
    return -1; // or appropriate error code
  }

  char *err;
  int status = opacity_core::init([api_key UTF8String], dry_run,
                                  static_cast<int>(environment),
                                  should_show_errors_in_webview, &err);
  if (status != opacity_core::OPACITY_OK && err != nullptr) {
    NSString *errorMessage = [NSString stringWithUTF8String:err];
    *error = parseOpacityError(errorMessage);
    opacity_core::free_string(err);
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
          NSString *error_str = [NSString stringWithUTF8String:err];
          NSError *opacity_error = parseOpacityError(error_str);
          opacity_core::free_string(err);
          completion(nil, opacity_error);
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
