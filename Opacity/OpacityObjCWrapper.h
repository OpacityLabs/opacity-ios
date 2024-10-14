#import <Foundation/Foundation.h>

@interface OpacityObjCWrapper : NSObject

+ (NSDictionary *)getUberRiderProfile;
+ (NSDictionary *)getUberRiderTripHistory:(NSInteger)limit
                                andOffset:(NSInteger)offset;
+ (NSDictionary *)getUberRiderTrip:(NSString *)uuid;
+ (NSDictionary *)getUberDriverProfile;
+ (NSDictionary *)getUberDriverTrips:(NSString *)startDate
                          andEndDate:(NSString *)endDate
                           andCursor:(NSString *)cursor;
+ (NSDictionary *)getUberFareEstimate:(NSNumber *)pickupLatitude
                   andPickupLongitude:(NSNumber *)pickupLongitude
               andDestinationLatitude:(NSNumber *)destinationLatitude
              andDestinationLongitude:(NSNumber *)destinationLongitude;
+(NSDictionary *)getRedditAccount;
+(NSDictionary *)getRedditFollowedSubreddits;
+(NSDictionary *)getRedditComments;
+(NSDictionary *)getRedditPosts;
+(NSDictionary *)getZabkaAccount;
+(NSDictionary *)getZabkaPoints;
@end
