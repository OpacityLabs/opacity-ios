#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OpacityEnvironment) {
  Test,
  Local,
  Staging,
  Production
};

@interface OpacityObjCWrapper : NSObject

+ (int)initialize:(NSString *)apiKey
                       andDryRun:(BOOL)dryRun
                  andEnvironment:(OpacityEnvironment)environment
    andShouldShowErrorsInWebview:(BOOL)shouldShowErrorsInWebview;

+ (void)get:(NSString *)name
     andParams:(NSDictionary *)params
    completion:(void (^)(NSDictionary *res, NSError *error))completion;

//// Reddit
//+ (void)getRedditAccount:(void (^)(NSString *json, NSString *proof,
//                                   NSError *error))completion;
//+ (void)getRedditFollowedSubreddits:(void (^)(NSString *json, NSString *proof,
//                                              NSError *error))completion;
//+ (void)getRedditComments:(void (^)(NSString *json, NSString *proof,
//                                    NSError *error))completion;
//+ (void)getRedditPosts:(void (^)(NSString *json, NSString *proof,
//                                 NSError *error))completion;
////  Zabka
//+ (void)getZabkaAccount:(void (^)(NSString *json, NSString *proof,
//                                  NSError *error))completion;
//+ (void)getZabkaPoints:(void (^)(NSString *json, NSString *proof,
//                                 NSError *error))completion;
//// Carta
//+ (void)getCartaProfile:(void (^)(NSString *json, NSString *proof,
//                                  NSError *error))completion;
//+ (void)getCartaOrganizations:(void (^)(NSString *json, NSString *proof,
//                                        NSError *error))completion;
//+ (void)getCartaPortfolioInvestments:(NSString *)firm_id
//                        andAccountId:(NSString *)account_id
//                       andCompletion:(void (^)(NSString *json, NSString
//                       *proof,
//                                               NSError *error))completion;
//+ (void)getCartaHoldingsCompanies:(NSString *)accountId
//                    ancCompletion:(void (^)(NSString *json, NSString *proof,
//                                            NSError *error))completion;
//+ (void)getCartaCorporationSecurities:(NSString *)account_id
//                     andCorporationId:(NSString *)corporation_id
//                        andCompletion:(void (^)(NSString *json, NSString
//                        *proof,
//                                                NSError *error))completion;
//// github
//+ (void)getGithubProfile:(void (^)(NSString *json, NSString *proof,
//                                   NSError *error))completion;
//
//// instagram
//+ (void)getInstagramProfile:(void (^)(NSString *json, NSString *proof,
//                                      NSError *error))completion;
//
//+ (void)getInstagramLikes:(void (^)(NSString *json, NSString *proof,
//                                    NSError *error))completion;
//
//+ (void)getInstagramComments:(void (^)(NSString *json, NSString *proof,
//                                       NSError *error))completion;
//
//+ (void)getInstagramSavedPosts:(void (^)(NSString *json, NSString *proof,
//                                         NSError *error))completion;
//
//
//
//+ (void)getGustoMembersTable:(void (^)(NSString *json, NSString *proof,
//                                       NSError *error))completion;
//
//+ (void)getGustoPayrollAdminId:(void (^)(NSString *json, NSString *proof,
//                                         NSError *error))completion;
@end
