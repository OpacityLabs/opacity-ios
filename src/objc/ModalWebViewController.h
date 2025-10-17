#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface ModalWebViewController
    : UIViewController <WKNavigationDelegate, NSURLSessionTaskDelegate>

@property(nonatomic, copy) void (^onDismissCallback)(void);

- (instancetype)initWithRequest:(NSMutableURLRequest *)request
                      userAgent:(NSString *)userAgent;
- (void)close;
- (void)openRequest:(NSMutableURLRequest *)request;
- (NSDictionary *)getBrowserCookiesForCurrentUrl;
- (NSDictionary *)getBrowserCookiesForDomain:(NSString *)domain;
@end
