#import "OpacityObjCWrapper.h"
#import "opacity.h"

@implementation OpacityObjCWrapper

+ (void)handleStatus:(int)status
             res:(char *)res_ptr
             err:(char *)err_ptr
          completion:(void (^)(NSString *res, NSError *error))completion {
  if (status != opacity_core::OPACITY_OK) {
    NSString *errorMessage = [NSString stringWithUTF8String:err_ptr];
    NSError *error =
        [NSError errorWithDomain:@"com.opacity"
                            code:status
                        userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
    opacity_core::free_string(err_ptr);
    completion(nil, error);
  } else {
    NSString *res = [NSString stringWithUTF8String:res_ptr];
    opacity_core::free_string(res_ptr);
    completion(res, nil);
  }
}

+ (void)get:(NSString *)name
     andParams:(NSDictionary *)params
    completion:(void (^)(NSString *res, NSError *error))completion {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *res, *err;

        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                           options:0
                                                             error:&error];
        if (!jsonData) {
          completion(nil, error);
          return;
        }

        NSString *jsonString =
            [[NSString alloc] initWithData:jsonData
                                  encoding:NSUTF8StringEncoding];

        int status = opacity_core::get(
            [name UTF8String], [jsonString UTF8String], &res, &err);

        [self handleStatus:status
                   res:res
                   err:err
                completion:completion];
      });
}

+ (int)initialize:(NSString *)api_key
         andDryRun:(BOOL)dry_run
    andEnvironment:(OpacityEnvironment)environment {
  return opacity_core::init([api_key UTF8String], dry_run,
                            static_cast<int>(environment));
}
//
//+ (void)getRedditAccount:(void (^)(NSString *json, NSString *proof,
//                                   NSError *error))completion {
//  dispatch_async(
//      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        char *res, *err;
//
//        int status = opacity_core::get_reddit_account(&res, &err);
//
//        [self handleStatus:status
//                      res:res
//                       err:err
//                completion:completion];
//      });
//}
//
//+ (void)getRedditFollowedSubreddits:(void (^)(NSString *json, NSString *proof,
//                                              NSError *error))completion {
//  dispatch_async(
//      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        char *res, *err;
//
//        int status =
//            opacity_core::get_reddit_followed_subreddits(&res, &err);
//
//        [self handleStatus:status
//                      res:res
//                       err:err
//                completion:completion];
//      });
//}
//
//+ (void)getRedditComments:(void (^)(NSString *json, NSString *proof,
//                                    NSError *error))completion {
//  dispatch_async(
//      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        char *json, *proof, *err;
//
//        int status = opacity_core::get_reddit_comments(&json, &proof, &err);
//
//        [self handleStatus:status
//                      json:json
//                     proof:proof
//                       err:err
//                completion:completion];
//      });
//}
//
//+ (void)getRedditPosts:(void (^)(NSString *json, NSString *proof,
//                                 NSError *error))completion {
//  dispatch_async(
//      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        char *json, *proof, *err;
//
//        int status = opacity_core::get_reddit_posts(&json, &proof, &err);
//
//        [self handleStatus:status
//                      json:json
//                     proof:proof
//                       err:err
//                completion:completion];
//      });
//}
//
//+ (void)getZabkaAccount:(void (^)(NSString *json, NSString *proof,
//                                  NSError *error))completion {
//  dispatch_async(
//      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        char *json, *proof, *err;
//
//        int status = opacity_core::get_zabka_account(&json, &proof, &err);
//
//        [self handleStatus:status
//                      json:json
//                     proof:proof
//                       err:err
//                completion:completion];
//      });
//}
//
//+ (void)getZabkaPoints:(void (^)(NSString *json, NSString *proof,
//                                 NSError *error))completion {
//  dispatch_async(
//      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        char *json, *proof, *err;
//
//        int status = opacity_core::get_zabka_points(&json, &proof, &err);
//
//        [self handleStatus:status
//                      json:json
//                     proof:proof
//                       err:err
//                completion:completion];
//      });
//}
//
//+ (void)getCartaProfile:(void (^)(NSString *json, NSString *proof,
//                                  NSError *error))completion {
//  dispatch_async(
//      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        char *json, *proof, *err;
//
//        int status = opacity_core::get_carta_profile(&json, &proof, &err);
//
//        [self handleStatus:status
//                      json:json
//                     proof:proof
//                       err:err
//                completion:completion];
//      });
//}
//+ (void)getCartaOrganizations:(void (^)(NSString *json, NSString *proof,
//                                        NSError *error))completion {
//  dispatch_async(
//      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        char *json, *proof, *err;
//
//        int status = opacity_core::get_carta_organizations(&json, &proof, &err);
//
//        [self handleStatus:status
//                      json:json
//                     proof:proof
//                       err:err
//                completion:completion];
//      });
//}
//+ (void)getCartaPortfolioInvestments:(NSString *)firm_id
//                        andAccountId:(NSString *)account_id
//                       andCompletion:(void (^)(NSString *json, NSString *proof,
//                                               NSError *error))completion {
//  dispatch_async(
//      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        char *json, *proof, *err;
//
//        int status = opacity_core::get_carta_portfolio_investments(
//            [firm_id UTF8String], [account_id UTF8String], &json, &proof, &err);
//
//        [self handleStatus:status
//                      json:json
//                     proof:proof
//                       err:err
//                completion:completion];
//      });
//}
//+ (void)getCartaHoldingsCompanies:(NSString *)account_id
//                    ancCompletion:(void (^)(NSString *json, NSString *proof,
//                                            NSError *error))completion {
//  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
//                 ^{
//                   char *json, *proof, *err;
//
//                   int status = opacity_core::get_carta_holdings_companies(
//                       [account_id UTF8String], &json, &proof, &err);
//
//                   [self handleStatus:status
//                                 json:json
//                                proof:proof
//                                  err:err
//                           completion:completion];
//                 });
//}
//+ (void)getCartaCorporationSecurities:(NSString *)account_id
//                     andCorporationId:(NSString *)corporation_id
//                        andCompletion:(void (^)(NSString *json, NSString *proof,
//                                                NSError *error))completion {
//  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
//                 ^{
//                   char *json, *proof, *err;
//
//                   int status = opacity_core::get_carta_corporation_securities(
//                       [account_id UTF8String], [corporation_id UTF8String],
//                       &json, &proof, &err);
//
//                   [self handleStatus:status
//                                 json:json
//                                proof:proof
//                                  err:err
//                           completion:completion];
//                 });
//}
//
//+ (void)getGithubProfile:(void (^)(NSString *json, NSString *proof,
//                                   NSError *error))completion {
//  dispatch_async(
//      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        char *json, *proof, *err;
//
//        int status = opacity_core::get_github_profile(&json, &proof, &err);
//
//        [self handleStatus:status
//                      json:json
//                     proof:proof
//                       err:err
//                completion:completion];
//      });
//}
//
//+ (void)getInstagramProfile:(void (^)(NSString *json, NSString *proof,
//                                      NSError *error))completion {
//  dispatch_async(
//      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        char *json, *proof, *err;
//
//        int status = opacity_core::get_instagram_profile(&json, &proof, &err);
//
//        [self handleStatus:status
//                      json:json
//                     proof:proof
//                       err:err
//                completion:completion];
//      });
//}
//
//+ (void)getInstagramLikes:(void (^)(NSString *json, NSString *proof,
//                                    NSError *error))completion {
//  dispatch_async(
//      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        char *json, *proof, *err;
//
//        int status = opacity_core::get_instagram_likes(&json, &proof, &err);
//
//        [self handleStatus:status
//                      json:json
//                     proof:proof
//                       err:err
//                completion:completion];
//      });
//}
//
//+ (void)getInstagramComments:(void (^)(NSString *json, NSString *proof,
//                                       NSError *error))completion {
//  dispatch_async(
//      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        char *json, *proof, *err;
//
//        int status = opacity_core::get_instagram_comments(&json, &proof, &err);
//
//        [self handleStatus:status
//                      json:json
//                     proof:proof
//                       err:err
//                completion:completion];
//      });
//}
//
//+ (void)getInstagramSavedPosts:(void (^)(NSString *json, NSString *proof,
//                                         NSError *error))completion {
//  dispatch_async(
//      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        char *json, *proof, *err;
//
//        int status =
//            opacity_core::get_instagram_saved_posts(&json, &proof, &err);
//
//        [self handleStatus:status
//                      json:json
//                     proof:proof
//                       err:err
//                completion:completion];
//      });
//}
//
//+ (void)getGustoMembersTable:(void (^)(NSString *json, NSString *proof,
//                                       NSError *error))completion {
//  dispatch_async(
//      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        char *json, *proof, *err;
//
//        int status = opacity_core::get_gusto_members_table(&json, &proof, &err);
//
//        [self handleStatus:status
//                      json:json
//                     proof:proof
//                       err:err
//                completion:completion];
//      });
//}
//
//+ (void)getGustoPayrollAdminId:(void (^)(NSString *, NSString *,
//                                         NSError *))completion {
//  dispatch_async(
//      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        char *json, *proof, *err;
//
//        int status =
//            opacity_core::get_gusto_payroll_admin_id(&json, &proof, &err);
//
//        [self handleStatus:status
//                      json:json
//                     proof:proof
//                       err:err
//                completion:completion];
//      });
//}

@end
