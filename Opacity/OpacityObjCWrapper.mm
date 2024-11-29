#import "OpacityObjCWrapper.h"
#import "opacity.h"

@implementation OpacityObjCWrapper

+ (void)handleStatus:(int)status
                json:(char *)json
               proof:(char *)proof
                 err:(char *)err
          completion:(void (^)(NSString *json, NSString *proof,
                               NSError *error))completion {
  if (status != opacity_core::OPACITY_OK) {
    NSString *errorMessage = [NSString stringWithUTF8String:err];
    NSError *error =
        [NSError errorWithDomain:@"com.opacity"
                            code:status
                        userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
    completion(nil, nil, error);
  } else {
    NSString *jsonString = [NSString stringWithUTF8String:json];
    NSString *proofString = [NSString stringWithUTF8String:proof];
    completion(jsonString, proofString, nil);
  }
}

+ (int)initialize:(NSString *)api_key
         andDryRun:(BOOL)dry_run
    andEnvironment:(OpacityEnvironment)environment {
  return opacity_core::init([api_key UTF8String], dry_run, environment);
}

+ (void)getUberRiderProfile:(void (^)(NSString *json, NSString *proof,
                                      NSError *error))completion {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json, *proof, *err;

        int status = opacity_core::get_uber_rider_profile(&json, &proof, &err);

        [self handleStatus:status
                      json:json
                     proof:proof
                       err:err
                completion:completion];
      });
}

+ (void)getUberRiderTripHistory:(NSString *)cursor
                  andCompletion:
                      (void (^)(NSString *, NSString *, NSError *))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                 ^{
                   char *json, *proof, *err;

                   const char *c_cursor = [cursor UTF8String];

                   int status = opacity_core::get_uber_rider_trip_history(
                       c_cursor, &json, &proof, &err);

                   [self handleStatus:status
                                 json:json
                                proof:proof
                                  err:err
                           completion:completion];
                 });
}

+ (void)getUberRiderTrip:(NSString *)uuid
           andCompletion:
               (void (^)(NSString *, NSString *, NSError *))completion {

  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json, *proof, *err;
        const char *c_uuid = [uuid UTF8String];

        int status =
            opacity_core::get_uber_rider_trip(c_uuid, &json, &proof, &err);

        [self handleStatus:status
                      json:json
                     proof:proof
                       err:err
                completion:completion];
      });
}

+ (void)getUberDriverProfile:(void (^)(NSString *json, NSString *proof,
                                       NSError *error))completion {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json, *proof, *err;

        int status = opacity_core::get_uber_driver_profile(&json, &proof, &err);

        [self handleStatus:status
                      json:json
                     proof:proof
                       err:err
                completion:completion];
      });
}

+ (void)getUberDriverTrips:(NSString *)startDate
                andEndDate:(NSString *)endDate
                 andCursor:(NSString *)cursor
             andCompletion:
                 (void (^)(NSString *, NSString *, NSError *))completion {
  const char *c_start_date = [startDate UTF8String];
  const char *c_end_date = [endDate UTF8String];
  const char *c_cursor = [cursor UTF8String];

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                 ^{
                   char *json, *proof, *err;

                   int status = opacity_core::get_uber_driver_trips(
                       c_start_date, c_end_date, c_cursor, &json, &proof, &err);

                   [self handleStatus:status
                                 json:json
                                proof:proof
                                  err:err
                           completion:completion];
                 });
}

+ (void)getUberFareEstimate:(NSNumber *)pickupLatitude
         andPickupLongitude:(NSNumber *)pickupLongitude
     andDestinationLatitude:(NSNumber *)destinationLatitude
    andDestinationLongitude:(NSNumber *)destinationLongitude
              andCompletion:
                  (void (^)(NSString *, NSString *, NSError *))completion {
  double c_pickup_latitude = [pickupLatitude doubleValue];
  double c_pickup_longitude = [pickupLongitude doubleValue];
  double c_destination_latitude = [destinationLatitude doubleValue];
  double c_destination_longitude = [destinationLongitude doubleValue];

  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json, *proof, *err;

        int status = opacity_core::get_uber_fare_estimate(
            c_pickup_latitude, c_pickup_longitude, c_destination_latitude,
            c_destination_longitude, &json, &proof, &err);

        [self handleStatus:status
                      json:json
                     proof:proof
                       err:err
                completion:completion];
      });
}

+ (void)getRedditAccount:(void (^)(NSString *json, NSString *proof,
                                   NSError *error))completion {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json, *proof, *err;

        int status = opacity_core::get_reddit_account(&json, &proof, &err);

        [self handleStatus:status
                      json:json
                     proof:proof
                       err:err
                completion:completion];
      });
}

+ (void)getRedditFollowedSubreddits:(void (^)(NSString *json, NSString *proof,
                                              NSError *error))completion {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json, *proof, *err;

        int status =
            opacity_core::get_reddit_followed_subreddits(&json, &proof, &err);

        [self handleStatus:status
                      json:json
                     proof:proof
                       err:err
                completion:completion];
      });
}

+ (void)getRedditComments:(void (^)(NSString *json, NSString *proof,
                                    NSError *error))completion {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json, *proof, *err;

        int status = opacity_core::get_reddit_comments(&json, &proof, &err);

        [self handleStatus:status
                      json:json
                     proof:proof
                       err:err
                completion:completion];
      });
}

+ (void)getRedditPosts:(void (^)(NSString *json, NSString *proof,
                                 NSError *error))completion {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json, *proof, *err;

        int status = opacity_core::get_reddit_posts(&json, &proof, &err);

        [self handleStatus:status
                      json:json
                     proof:proof
                       err:err
                completion:completion];
      });
}

+ (void)getZabkaAccount:(void (^)(NSString *json, NSString *proof,
                                  NSError *error))completion {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json, *proof, *err;

        int status = opacity_core::get_zabka_account(&json, &proof, &err);

        [self handleStatus:status
                      json:json
                     proof:proof
                       err:err
                completion:completion];
      });
}

+ (void)getZabkaPoints:(void (^)(NSString *json, NSString *proof,
                                 NSError *error))completion {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json, *proof, *err;

        int status = opacity_core::get_zabka_points(&json, &proof, &err);

        [self handleStatus:status
                      json:json
                     proof:proof
                       err:err
                completion:completion];
      });
}

+ (void)getCartaProfile:(void (^)(NSString *json, NSString *proof,
                                  NSError *error))completion {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json, *proof, *err;

        int status = opacity_core::get_carta_profile(&json, &proof, &err);

        [self handleStatus:status
                      json:json
                     proof:proof
                       err:err
                completion:completion];
      });
}
+ (void)getCartaOrganizations:(void (^)(NSString *json, NSString *proof,
                                        NSError *error))completion {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json, *proof, *err;

        int status = opacity_core::get_carta_organizations(&json, &proof, &err);

        [self handleStatus:status
                      json:json
                     proof:proof
                       err:err
                completion:completion];
      });
}
+ (void)getCartaPortfolioInvestments:(NSString *)firm_id
                        andAccountId:(NSString *)account_id
                       andCompletion:(void (^)(NSString *json, NSString *proof,
                                               NSError *error))completion {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json, *proof, *err;

        int status = opacity_core::get_carta_portfolio_investments(
            [firm_id UTF8String], [account_id UTF8String], &json, &proof, &err);

        [self handleStatus:status
                      json:json
                     proof:proof
                       err:err
                completion:completion];
      });
}
+ (void)getCartaHoldingsCompanies:(NSString *)account_id
                    ancCompletion:(void (^)(NSString *json, NSString *proof,
                                            NSError *error))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                 ^{
                   char *json, *proof, *err;

                   int status = opacity_core::get_carta_holdings_companies(
                       [account_id UTF8String], &json, &proof, &err);

                   [self handleStatus:status
                                 json:json
                                proof:proof
                                  err:err
                           completion:completion];
                 });
}
+ (void)getCartaCorporationSecurities:(NSString *)account_id
                     andCorporationId:(NSString *)corporation_id
                        andCompletion:(void (^)(NSString *json, NSString *proof,
                                                NSError *error))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                 ^{
                   char *json, *proof, *err;

                   int status = opacity_core::get_carta_corporation_securities(
                       [account_id UTF8String], [corporation_id UTF8String],
                       &json, &proof, &err);

                   [self handleStatus:status
                                 json:json
                                proof:proof
                                  err:err
                           completion:completion];
                 });
}

+ (void)getGithubProfile:(void (^)(NSString *json, NSString *proof,
                                   NSError *error))completion {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *json, *proof, *err;

        int status = opacity_core::get_github_profile(&json, &proof, &err);

        [self handleStatus:status
                      json:json
                     proof:proof
                       err:err
                completion:completion];
      });
}

+ (void)runLua {
  opacity_core::run_lua();
}

@end
