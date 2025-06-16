#import "ModalWebViewController.h"
#import "OpacityIOSHelper.h"
#import "opacity.h"

@interface ModalWebViewController ()

@property(nonatomic, strong) WKWebView *webView;
@property(nonatomic, strong) NSMutableURLRequest *request;
@property(nonatomic, strong) WKWebsiteDataStore *websiteDataStore;
@property(nonatomic, strong) NSMutableDictionary *cookies;
@property(nonatomic, strong) NSMutableArray<NSString *> *visitedUrls;
@property(nonatomic, strong) NSString *customUserAgent;

@end

@implementation ModalWebViewController
- (void)viewDidLoad {
  [super viewDidLoad];

  self.cookies = [NSMutableDictionary dictionary];
  self.visitedUrls = [NSMutableArray array];

  // Configure the view's background color
  self.view.backgroundColor = [UIColor blackColor];

  WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];

  WKProcessPool *processPool = [[WKProcessPool alloc] init];
  configuration.processPool = processPool;

  self.websiteDataStore = [WKWebsiteDataStore nonPersistentDataStore];
  configuration.websiteDataStore = self.websiteDataStore;

  // Initialize and configure the WKWebView
  self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds
                                    configuration:configuration];

  // URL listener for SPAs
  [self.webView addObserver:self
                 forKeyPath:@"URL"
                    options:NSKeyValueObservingOptionNew
                    context:nil];

  // Set the configuration to the WKWebView
  self.webView.allowsLinkPreview = true;
  self.webView.autoresizingMask =
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.webView.navigationDelegate = self;

  // Add the WKWebView to the view hierarchy
  [self.view addSubview:self.webView];

  // Set the custom user agent if provided
  if (self.customUserAgent != nil) {
    self.webView.customUserAgent = self.customUserAgent;
  }

  // Load the provided URL
  if (self.request) {
    [self.webView loadRequest:self.request];
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  // Add navigation items after the view hierarchy is fully set up
  if (!self.navigationItem.rightBarButtonItem) {
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                             target:self
                             action:@selector(close)];
    self.navigationItem.rightBarButtonItem = closeButton;
  }
}

+ (BOOL)accessInstanceVariablesDirectly {
  return NO;
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  // Check if the controller or its navigation controller is being dismissed
  if (self.isBeingDismissed || self.navigationController.isBeingDismissed) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *event_id = [NSString
        stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    [dict setObject:@"close" forKey:@"event"];
    [dict setObject:event_id forKey:@"id"];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    NSString *payload = [[NSString alloc] initWithData:jsonData
                                              encoding:NSUTF8StringEncoding];

    opacity_core::emit_webview_event([payload UTF8String]);
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
  if (![keyPath isEqualToString:@"URL"] || object != self.webView) {
    return;
  }

  NSURL *newURL = change[NSKeyValueChangeNewKey];
  if (!newURL) {
    return;
  }

  [self addToVisitedUrls:newURL.absoluteString];

  NSDictionary *event = @{
    @"event" : @"location_changed",
    @"url" : newURL.absoluteString,
    @"id" : [NSString
        stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000]
  };

  NSError *error = nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:event
                                                     options:0
                                                       error:&error];
  if (!jsonData) {
    return;
  }

  NSString *payload = [[NSString alloc] initWithData:jsonData
                                            encoding:NSUTF8StringEncoding];
  opacity_core::emit_webview_event([payload UTF8String]);
}

- (void)dealloc {
  [self.webView removeObserver:self forKeyPath:@"URL"];
}

- (void)getBrowserCookiesForDomainWithCompletion:(NSString *)domain
                                      completion:
                                          (void (^)(NSDictionary *))completion {
  NSMutableDictionary *cookieDict = [NSMutableDictionary dictionary];
  WKHTTPCookieStore *cookieStore =
      self.webView.configuration.websiteDataStore.httpCookieStore;

  [cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> *cookies) {
    for (NSHTTPCookie *cookie in cookies) {
      // Check if the cookie's domain matches the target domain
      // This handles both exact matches and subdomain matches
      if ([domain hasSuffix:cookie.domain] ||
          [domain isEqualToString:cookie.domain]) {
        [cookieDict setObject:cookie.value forKey:cookie.name];
      }
    }
    completion(cookieDict);
  }];
}

- (NSDictionary *)getBrowserCookiesForDomain:(NSString *)domain {
  __block NSDictionary *result = nil;
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

  [self getBrowserCookiesForDomainWithCompletion:domain
                                      completion:^(NSDictionary *cookies) {
                                        result = cookies;
                                        dispatch_semaphore_signal(semaphore);
                                      }];

  dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
  return result;
}
- (NSDictionary *)getBrowserCookiesForCurrentUrl {
  __block NSDictionary *result = nil;
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

  void (^getCookiesBlock)(void) = ^{
    NSURL *url = self.webView.URL;
    if (url == nil) {
      result = [NSMutableDictionary dictionary];
      dispatch_semaphore_signal(semaphore);
      return;
    }

    [self getBrowserCookiesForDomainWithCompletion:url.host
                                        completion:^(NSDictionary *cookies) {
                                          result = cookies;
                                          dispatch_semaphore_signal(semaphore);
                                        }];
  };

  if ([NSThread isMainThread]) {
    getCookiesBlock();
  } else {
    dispatch_async(dispatch_get_main_queue(), getCookiesBlock);
  }

  dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
  return result;
}

- (void)updateCapturedCookiesWithCompletion:(void (^)(void))completion {
  WKHTTPCookieStore *cookieStore =
      self.webView.configuration.websiteDataStore.httpCookieStore;

  [cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> *cookies) {
    for (NSHTTPCookie *cookie in cookies) {
      [self.cookies setObject:cookie.value forKey:cookie.name];
    }
    completion();
  }];
}

- (void)openRequest:(NSMutableURLRequest *)request {
  _request = request;
  [self.webView loadRequest:_request];
}

- (instancetype)initWithRequest:(NSMutableURLRequest *)request
                      userAgent:(NSString *)userAgent {
  self = [super init];

  if (self) {
    _request = request;
    _customUserAgent = userAgent;
  }
  return self;
}

- (void)close {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addToVisitedUrls:(NSString *)urlToAdd {
  if (self.visitedUrls.count == 0 ||
      ![self.visitedUrls.lastObject isEqualToString:urlToAdd]) {
    [self.visitedUrls addObject:urlToAdd];
  }
}

- (void)resetVisitedUrls {
  [self.visitedUrls removeAllObjects];
}

#pragma mark - WKNavigationDelegate Methods

- (void)webView:(WKWebView *)webView
    didStartProvisionalNavigation:(WKNavigation *)navigation {
  if (webView.URL) {
    [self addToVisitedUrls:webView.URL.absoluteString];
  }
}

- (void)getHtmlBodyWithCompletion:(void (^)(NSString *))completion {
  [self.webView
      evaluateJavaScript:@"document.documentElement.outerHTML.toString()"
       completionHandler:^(NSString *html, NSError *error) {
         completion(html);
       }];
}

- (void)webView:(WKWebView *)webView
    didFinishNavigation:(WKNavigation *)navigation {
  NSURL *url = webView.URL;

  if (!url) {
    return;
  }

  [self addToVisitedUrls:webView.URL.absoluteString];
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  NSString *event_id =
      [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
  [dict setObject:url.absoluteString forKey:@"url"];
  [dict setObject:@"navigation" forKey:@"event"];
  [dict setObject:event_id forKey:@"id"];

  [self getHtmlBodyWithCompletion:^(NSString *body) {
    if (body != nil) {
      [dict setObject:body forKey:@"html_body"];
    }

    [self updateCapturedCookiesWithCompletion:^{
      [dict setObject:self.cookies forKey:@"cookies"];
      [dict setObject:self.visitedUrls forKey:@"visited_urls"];

      NSError *error;
      NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                         options:0
                                                           error:&error];
      NSString *payload = [[NSString alloc] initWithData:jsonData
                                                encoding:NSUTF8StringEncoding];

      opacity_core::emit_webview_event([payload UTF8String]);

      [self resetVisitedUrls];
    }];
  }];
}

- (void)webView:(WKWebView *)webView
    didReceiveServerRedirectForProvisionalNavigation:
        (WKNavigation *)navigation {
  NSURL *url = webView.URL;

  if (url) {
    [self addToVisitedUrls:url.absoluteString];
  }
}

- (void)webView:(WKWebView *)webView
    didFailProvisionalNavigation:(WKNavigation *)navigation
                       withError:(NSError *)error {
  NSString *url = error.userInfo[NSURLErrorFailingURLStringErrorKey];

  if (!url) {
    return;
  }

  [self addToVisitedUrls:url];
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  [dict setObject:url forKey:@"url"];
  [dict setObject:@"navigation" forKey:@"event"];
  [dict setObject:[NSString stringWithFormat:@"%f", [[NSDate date]
                                                        timeIntervalSince1970]]
           forKey:@"id"];

  [dict setObject:self.cookies forKey:@"cookies"];
  [dict setObject:self.visitedUrls forKey:@"visited_urls"];

  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                     options:0
                                                       error:&error];

  NSString *payload = [[NSString alloc] initWithData:jsonData
                                            encoding:NSUTF8StringEncoding];

  opacity_core::emit_webview_event([payload UTF8String]);
  [self resetVisitedUrls];
}

- (void)URLSession:(NSURLSession *)session
                          task:(NSURLSessionTask *)task
    willPerformHTTPRedirection:(NSHTTPURLResponse *)response
                    newRequest:(NSURLRequest *)request
             completionHandler:
                 (void (^)(NSURLRequest *_Nullable))completionHandler {

  NSDictionary *headers = [response allHeaderFields];

  NSArray *cookies =
      [NSHTTPCookie cookiesWithResponseHeaderFields:headers
                                             forURL:[response URL]];

  for (NSHTTPCookie *cookie in cookies) {
    [self.cookies setObject:cookie.value forKey:cookie.name];
  }

  if (request.URL) {
    [self addToVisitedUrls:request.URL.absoluteString];
  }
  if (response.URL) {
    [self addToVisitedUrls:response.URL.absoluteString];
  }
  completionHandler(request);
}

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:
                        (void (^)(WKNavigationActionPolicy))decisionHandler {

  /// We potentially want to intercept navigation requests with deeplinks
  /// A deeplink might take you out of the current app and into the service app
  /// The problem is by canceling the redirection none of the other handlers are
  /// triggered. Which means the cookies at the moment of the redirection are
  /// not sent to Rust. We could potentially move the code of
  /// didFailProvisionalNavigation here and it might work... I don't know, this
  /// needs testing. For now allowing all redirections causes the deeplinks we
  /// need to fail which then triggeres didFailProvisionalNavigation and
  /// extracts and sends the requests to Rust and then to Lua
  //  NSURLRequest *request = navigationAction.request;
  //  NSURL *url = request.URL;
  //  if (![url.scheme isEqualToString:@"http"] &&
  //      ![url.scheme isEqualToString:@"https"]) {
  //    decisionHandler(WKNavigationActionPolicyCancel);
  //    return;
  //  }

  if (webView.URL) {
    [self addToVisitedUrls:webView.URL.absoluteString];
  }

  decisionHandler(WKNavigationActionPolicyAllow);
}

@end
