#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface ModalWebViewController
    : UIViewController <WKNavigationDelegate, NSURLSessionTaskDelegate>

// Add a typedef for the cleanup function pointer
typedef void (*CleanupFunctionPointer)(void);

- (instancetype)initWithRequest:(NSMutableURLRequest *)request
                      userAgent:(NSString *)userAgent
                cleanupFunction:(CleanupFunctionPointer)cleanupFunction;
- (void)close;
- (void)openRequest:(NSMutableURLRequest *)request;
- (NSDictionary *)getBrowserCookiesForCurrentUrl;
- (NSDictionary *)getBrowserCookiesForDomain:(NSString *)domain;
@end
