#import "OpacityObjCWrapper.h"
#import "helper_functions.h"
#import "sdk.h"

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

  NSBundle *frameworkBundle =
      [NSBundle bundleWithIdentifier:@"com.opacitylabs.sdk"];
  if (![frameworkBundle isLoaded]) {
    BOOL success = [frameworkBundle load];
    if (!success) {
      NSString *errorMessage = @"Failed to load framework";
      *error =
          [NSError errorWithDomain:@"OpacitySDKDylibError"
                              code:1002
                          userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
      return -1;
    }

    opacity_core::register_ios_callbacks(
        ios_prepare_request, ios_set_request_header, ios_present_webview,
        ios_close_webview, ios_get_browser_cookies_for_current_url,
        ios_get_browser_cookies_for_domain, get_ip_address, get_battery_level,
        get_battery_status, get_carrier_name, get_carrier_mcc, get_carrier_mnc,
        get_course, get_cpu_abi, get_altitude, get_latitude, get_longitude,
        get_device_model, get_os_name, get_os_version, is_emulator,
        get_horizontal_accuracy, get_vertical_accuracy,
        is_location_services_enabled, is_wifi_connected, is_rooted);
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
