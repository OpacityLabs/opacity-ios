#import "OpacityObjCWrapper.h"
#import "opacity.h"

@implementation OpacityObjCWrapper

+ (NSDictionary *)getUberRiderProfile {
  char *json;
  char *proof;
  char *err;

  int status = opacity_core::get_uber_rider_profile(&json, &proof, &err);

  if (status != opacity_core::OPACITY_OK) {
    NSString *errorMessage = [NSString stringWithUTF8String:err];
    NSDictionary *errorDict = @{@"status" : @(status), @"error" : errorMessage};
    return errorDict;
  }

  NSString *profile = [NSString stringWithUTF8String:json];
  NSString *proofString = [NSString stringWithUTF8String:proof];
  NSDictionary *resultDict =
      @{@"status" : @(status), @"profile" : profile, @"proof" : proofString};
  return resultDict;
}

+ (NSDictionary *)getUberRiderTripHistory:(NSInteger)limit
                                andOffset:(NSInteger)offset {
  char *json;
  char *proof;
  char *err;

  int c_limit = static_cast<int>(limit);
  int c_offset = static_cast<int>(offset);

  int status = opacity_core::get_uber_rider_trip_history(c_limit, c_offset,
                                                         &json, &proof, &err);

  if (status != opacity_core::OPACITY_OK) {
    NSString *errorMessage = [NSString stringWithUTF8String:err];
    NSDictionary *errorDict = @{@"status" : @(status), @"error" : errorMessage};
    return errorDict;
  }

  NSString *profile = [NSString stringWithUTF8String:json];
  NSString *proofString = [NSString stringWithUTF8String:proof];
  NSDictionary *resultDict =
      @{@"status" : @(status), @"profile" : profile, @"proof" : proofString};
  return resultDict;
}

+ (NSDictionary *)getUberRiderTrip:(NSString *)uuid {
  char *json;
  char *proof;
  char *err;

  const char *c_uuid = [uuid UTF8String];

  int status = opacity_core::get_uber_rider_trip(c_uuid, &json, &proof, &err);

  if (status != opacity_core::OPACITY_OK) {
    NSString *errorMessage = [NSString stringWithUTF8String:err];
    NSDictionary *errorDict = @{@"status" : @(status), @"error" : errorMessage};
    return errorDict;
  }

  NSString *profile = [NSString stringWithUTF8String:json];
  NSString *proofString = [NSString stringWithUTF8String:proof];
  NSDictionary *resultDict =
      @{@"status" : @(status), @"profile" : profile, @"proof" : proofString};
  return resultDict;
}

+ (NSDictionary *)getUberDriverProfile {
  char *json;
  char *proof;
  char *err;

  int status = opacity_core::get_uber_driver_profile(&json, &proof, &err);

  if (status != opacity_core::OPACITY_OK) {
    NSString *errorMessage = [NSString stringWithUTF8String:err];
    NSDictionary *errorDict = @{@"status" : @(status), @"error" : errorMessage};
    return errorDict;
  }

  NSString *profile = [NSString stringWithUTF8String:json];
  NSString *proofString = [NSString stringWithUTF8String:proof];
  NSDictionary *resultDict =
      @{@"status" : @(status), @"profile" : profile, @"proof" : proofString};
  return resultDict;
}
+ (NSDictionary *)getUberDriverTrips:(NSString *)startDate
                          andEndDate:(NSString *)endDate
                           andCursor:(NSString *)cursor {
  char *json;
  char *proof;
  char *err;

  const char *c_start_date = [startDate UTF8String];
  const char *c_end_date = [endDate UTF8String];
  const char *c_cursor = [cursor UTF8String];

  int status = opacity_core::get_uber_driver_trips(
      c_start_date, c_end_date, c_cursor, &json, &proof, &err);

  if (status != opacity_core::OPACITY_OK) {
    NSString *errorMessage = [NSString stringWithUTF8String:err];
    NSDictionary *errorDict = @{@"status" : @(status), @"error" : errorMessage};
    return errorDict;
  }

  NSString *profile = [NSString stringWithUTF8String:json];
  NSString *proofString = [NSString stringWithUTF8String:proof];
  NSDictionary *resultDict =
      @{@"status" : @(status), @"profile" : profile, @"proof" : proofString};
  return resultDict;
}
+ (NSDictionary *)getUberFareEstimate:(NSNumber *)pickupLatitude
                   andPickupLongitude:(NSNumber *)pickupLongitude
               andDestinationLatitude:(NSNumber *)destinationLatitude
              andDestinationLongitude:(NSNumber *)destinationLongitude {
  char *json;
  char *proof;
  char *err;

  double c_pickup_latitude = [pickupLatitude doubleValue];
  double c_pickup_longitude = [pickupLongitude doubleValue];
  double c_destination_latitude = [destinationLatitude doubleValue];
  double c_destination_longitude = [destinationLongitude doubleValue];

  int status = opacity_core::get_uber_fare_estimate(
      c_pickup_latitude, c_pickup_longitude, c_destination_latitude,
      c_destination_longitude, &json, &proof, &err);

  if (status != opacity_core::OPACITY_OK) {
    NSString *errorMessage = [NSString stringWithUTF8String:err];
    NSDictionary *errorDict = @{@"status" : @(status), @"error" : errorMessage};
    return errorDict;
  }

  NSString *profile = [NSString stringWithUTF8String:json];
  NSString *proofString = [NSString stringWithUTF8String:proof];
  NSDictionary *resultDict =
      @{@"status" : @(status), @"profile" : profile, @"proof" : proofString};
  return resultDict;
}
+ (NSDictionary *)getRedditAccount {
    char *json;
        char *proof;
        char *err;

        int status = opacity_core::get_reddit_account(&json, &proof, &err);

        if (status != opacity_core::OPACITY_OK) {
          NSString *errorMessage = [NSString stringWithUTF8String:err];
          NSDictionary *errorDict = @{@"status" : @(status), @"error" : errorMessage};
          return errorDict;
        }

        NSString *profile = [NSString stringWithUTF8String:json];
        NSString *proofString = [NSString stringWithUTF8String:proof];
        NSDictionary *resultDict =
            @{@"status" : @(status), @"profile" : profile, @"proof" : proofString};
        return resultDict;
}

+ (NSDictionary *)getRedditFollowedSubreddits {
    char *json;
        char *proof;
        char *err;

    int status = opacity_core::get_reddit_followed_subreddits(&json, &proof, &err);

        if (status != opacity_core::OPACITY_OK) {
          NSString *errorMessage = [NSString stringWithUTF8String:err];
          NSDictionary *errorDict = @{@"status" : @(status), @"error" : errorMessage};
          return errorDict;
        }

        NSString *profile = [NSString stringWithUTF8String:json];
        NSString *proofString = [NSString stringWithUTF8String:proof];
        NSDictionary *resultDict =
            @{@"status" : @(status), @"profile" : profile, @"proof" : proofString};
        return resultDict;
}

+ (NSDictionary *)getRedditComments {
    char *json;
        char *proof;
        char *err;

        int status = opacity_core::get_reddit_comments(&json, &proof, &err);

        if (status != opacity_core::OPACITY_OK) {
          NSString *errorMessage = [NSString stringWithUTF8String:err];
          NSDictionary *errorDict = @{@"status" : @(status), @"error" : errorMessage};
          return errorDict;
        }

        NSString *profile = [NSString stringWithUTF8String:json];
        NSString *proofString = [NSString stringWithUTF8String:proof];
        NSDictionary *resultDict =
            @{@"status" : @(status), @"profile" : profile, @"proof" : proofString};
        return resultDict;
}
+ (NSDictionary *)getRedditPosts {
    char *json;
        char *proof;
        char *err;

        int status = opacity_core::get_reddit_posts(&json, &proof, &err);

        if (status != opacity_core::OPACITY_OK) {
          NSString *errorMessage = [NSString stringWithUTF8String:err];
          NSDictionary *errorDict = @{@"status" : @(status), @"error" : errorMessage};
          return errorDict;
        }

        NSString *profile = [NSString stringWithUTF8String:json];
        NSString *proofString = [NSString stringWithUTF8String:proof];
        NSDictionary *resultDict =
            @{@"status" : @(status), @"profile" : profile, @"proof" : proofString};
        return resultDict;
}
+ (NSDictionary *)getZabkaAccount {
    char *json;
        char *proof;
        char *err;

        int status = opacity_core::get_zabka_account(&json, &proof, &err);

        if (status != opacity_core::OPACITY_OK) {
          NSString *errorMessage = [NSString stringWithUTF8String:err];
          NSDictionary *errorDict = @{@"status" : @(status), @"error" : errorMessage};
          return errorDict;
        }

        NSString *profile = [NSString stringWithUTF8String:json];
        NSString *proofString = [NSString stringWithUTF8String:proof];
        NSDictionary *resultDict =
            @{@"status" : @(status), @"profile" : profile, @"proof" : proofString};
        return resultDict;
}
+ (NSDictionary *)getZabkaPoints {
    char *json;
        char *proof;
        char *err;

        int status = opacity_core::get_zabka_points(&json, &proof, &err);

        if (status != opacity_core::OPACITY_OK) {
          NSString *errorMessage = [NSString stringWithUTF8String:err];
          NSDictionary *errorDict = @{@"status" : @(status), @"error" : errorMessage};
          return errorDict;
        }

        NSString *profile = [NSString stringWithUTF8String:json];
        NSString *proofString = [NSString stringWithUTF8String:proof];
        NSDictionary *resultDict =
            @{@"status" : @(status), @"profile" : profile, @"proof" : proofString};
        return resultDict;
}

@end
