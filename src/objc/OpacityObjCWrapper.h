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
    andShouldShowErrorsInWebview:(BOOL)shouldShowErrorsInWebview
                        andError:(NSError **)error;

+ (void)get:(NSString *)name
     andParams:(NSDictionary *)params
    completion:(void (^)(NSDictionary *res, NSError *error))completion;

@end
