#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface ModalWebViewController
    : UIViewController <WKNavigationDelegate, NSURLSessionTaskDelegate, WKScriptMessageHandler>

@property(nonatomic, copy) void (^onDismissCallback)(void);

- (instancetype)initWithRequest:(NSMutableURLRequest *)request
                      userAgent:(NSString *)userAgent
              interceptRequests:(bool)interceptRequests;
- (void)close;
- (void)openRequest:(NSMutableURLRequest *)request;
- (NSDictionary *)getBrowserCookiesForCurrentUrl;
- (NSDictionary *)getBrowserCookiesForDomain:(NSString *)domain;
- (NSDictionary *)getLocalStorageForCurrentUrl;
- (NSDictionary *)getSessionStorageForCurrentUrl;
@end
