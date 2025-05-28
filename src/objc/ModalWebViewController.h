#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface ModalWebViewController
    : UIViewController <WKNavigationDelegate, NSURLSessionTaskDelegate>
- (instancetype)initWithRequest:(NSMutableURLRequest *)request userAgent:(NSString *)userAgent;
- (void)close;
- (void)openRequest:(NSMutableURLRequest *)request;
- (NSDictionary *)getBrowserCookiesForCurrentUrl;
- (NSDictionary *)getBrowserCookiesForDomain:(NSString *)domain;
@end
