#import "ModalWebViewController.h"
#import "sdk.h"

static NSString *opacityStringFromOwnedCString(const char *raw) {
  if (!raw) {
    return @"";
  }

  NSString *value = [NSString stringWithUTF8String:raw] ?: @"";
  opacity_core::free_string((char *)raw);
  return value;
}

static NSString *opacity_rendered_html_observer_script(void) {
  return opacityStringFromOwnedCString(opacity_core::get_browser_overlay_observer_script());
}

static NSString *opacity_browser_overlay_pages_bootstrap_script(void) {
  NSString *pagesJson = opacityStringFromOwnedCString(opacity_core::get_browser_overlay_pages_json());
  if (!pagesJson.length) {
    pagesJson = @"[]";
  }

  return [NSString stringWithFormat:
      @"(function() {\n"
      @"  window.__opacityOverlayPages = %@;\n"
      @"})();", pagesJson];
}

@interface ModalWebViewController ()
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, copy) NSString *customUserAgent;
@property (nonatomic, strong) WKWebsiteDataStore *websiteDataStore;
@property (nonatomic, strong) NSMutableDictionary *cookies;
@property (nonatomic, strong) NSMutableArray *visitedUrls;
@property (nonatomic, assign) NSInteger eventCounter;
@property (nonatomic, assign) bool interceptRequests;
@property (nonatomic, strong) NSArray<NSHTTPCookie *> *initialCookies;
@end

@implementation ModalWebViewController

- (void)presentGeneratedOverlayWithMapperJson:(NSString *)mapperJson {
  NSData *mapperLiteralData =
      [NSJSONSerialization dataWithJSONObject:@[ mapperJson ] options:0 error:nil];
  if (!mapperLiteralData) {
    return;
  }

  NSString *mapperLiteralArray =
      [[NSString alloc] initWithData:mapperLiteralData encoding:NSUTF8StringEncoding];
  if (!mapperLiteralArray.length || mapperLiteralArray.length < 2) {
    return;
  }
  NSString *mapperLiteral =
      [mapperLiteralArray substringWithRange:NSMakeRange(1, mapperLiteralArray.length - 2)];
  if (!mapperLiteral) {
    return;
  }

  NSString *rendererScriptTemplate =
      opacityStringFromOwnedCString(opacity_core::get_browser_overlay_renderer_script());
  if (!rendererScriptTemplate.length) {
    return;
  }

  NSString *script = [NSString stringWithFormat:rendererScriptTemplate, mapperLiteral];

  [self evalJs:script timeout:0];
}

- (void)viewDidLoad {
  [super viewDidLoad]; 

  self.cookies = [NSMutableDictionary dictionary];
  self.visitedUrls = [NSMutableArray array];
  self.eventCounter = 0;

  // Configure the view's background color
  self.view.backgroundColor = [UIColor blackColor];

  WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];

  WKProcessPool *processPool = [[WKProcessPool alloc] init];
  configuration.processPool = processPool;

  self.websiteDataStore = [WKWebsiteDataStore nonPersistentDataStore];
  configuration.websiteDataStore = self.websiteDataStore;

  
  WKUserContentController *contentController = [[WKUserContentController alloc] init];

  if (opacity_core::is_browser_overlay_enabled()) {
    WKUserScript *overlayPagesScript =
        [[WKUserScript alloc] initWithSource:opacity_browser_overlay_pages_bootstrap_script()
                               injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                            forMainFrameOnly:YES];
    [contentController addUserScript:overlayPagesScript];
    WKUserScript *renderedHtmlObserverScript =
        [[WKUserScript alloc] initWithSource:opacity_rendered_html_observer_script()
                               injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                            forMainFrameOnly:YES];
    [contentController addUserScript:renderedHtmlObserverScript];
    [contentController addScriptMessageHandler:self name:@"renderedHtmlReady"];
  }

  if (self.interceptRequests) {
    NSString *injectedJS =
    @"(function() {\n"
    "    const handler = window.webkit.messageHandlers.interceptedRequestHandler;\n"
    "    const log = (requestType, data) => { try { handler.postMessage({ requestType, data }); } catch(e) {} };\n"
    "    \n"
    "    const nativeToString = Function.prototype.toString;\n"
    "    const nativeCallToString = Function.prototype.call.bind(nativeToString);\n"
    "    const wrappedFns = new WeakMap();\n"
    "    \n"
    "    Function.prototype.toString = function() {\n"
    "        if (wrappedFns.has(this)) {\n"
    "            return wrappedFns.get(this);\n"
    "        }\n"
    "        return nativeCallToString(this);\n"
    "    };\n"
    "    wrappedFns.set(Function.prototype.toString, 'function toString() { [native code] }');\n"
    "    \n"
    "    const originalFetch = window.fetch;\n"
    "    const wrappedFetch = function fetch(input, init) {\n"
    "        const method = (init && init.method) || (typeof input === 'string' ? 'GET' : input.method || 'GET');\n"
    "        const url = typeof input === 'string' ? input : input.url;\n"
    "        let requestHeaders = init?.headers || {};\n"
    "        if (requestHeaders instanceof Headers) requestHeaders = Object.fromEntries(requestHeaders.entries());\n"
    "        log('fetch_request', { url, method, headers: requestHeaders, body: init?.body });\n"
    "        return originalFetch.apply(this, arguments).then(function(response) {\n"
    "            const cloned = response.clone();\n"
    "            let responseHeaders = cloned.headers || {};\n"
    "            if (responseHeaders instanceof Headers) responseHeaders = Object.fromEntries(responseHeaders.entries());\n"
    "            cloned.text().then(function(body) {\n"
    "                log('fetch_response', { url, method, headers: responseHeaders, body, status: cloned.status });\n"
    "            });\n"
    "            return response;\n"
    "        });\n"
    "    };\n"
    "    wrappedFns.set(wrappedFetch, 'function fetch() { [native code] }');\n"
    "    Object.defineProperty(window, 'fetch', { value: wrappedFetch, writable: true, configurable: true });\n"
    "    \n"
    "    const OriginalXHR = window.XMLHttpRequest;\n"
    "    const xhrProto = OriginalXHR.prototype;\n"
    "    const originalOpen = xhrProto.open;\n"
    "    const originalSend = xhrProto.send;\n"
    "    const originalSetHeader = xhrProto.setRequestHeader;\n"
    "    const xhrData = new WeakMap();\n"
    "    \n"
    "    xhrProto.open = function(method, url) {\n"
    "        xhrData.set(this, { method, url, headers: {} });\n"
    "        return originalOpen.apply(this, arguments);\n"
    "    };\n"
    "    wrappedFns.set(xhrProto.open, 'function open() { [native code] }');\n"
    "    \n"
    "    xhrProto.setRequestHeader = function(name, value) {\n"
    "        const data = xhrData.get(this);\n"
    "        if (data) data.headers[name] = value;\n"
    "        return originalSetHeader.apply(this, arguments);\n"
    "    };\n"
    "    wrappedFns.set(xhrProto.setRequestHeader, 'function setRequestHeader() { [native code] }');\n"
    "    \n"
    "    xhrProto.send = function(body) {\n"
    "        const data = xhrData.get(this);\n"
    "        if (data) {\n"
    "            log('xhr_request', { method: data.method, url: data.url, headers: data.headers, body });\n"
    "            this.addEventListener('loadend', () => {\n"
    "                log('xhr_response', { method: data.method, url: data.url, headers: data.headers, body: this.responseText || this.response, status: this.status });\n"
    "            });\n"
    "        }\n"
    "        return originalSend.apply(this, arguments);\n"
    "    };\n"
    "    wrappedFns.set(xhrProto.send, 'function send() { [native code] }');\n"
    "    \n"
    "    Object.defineProperty(navigator, 'webdriver', { get: () => undefined, configurable: true });\n"
    "})();\n";

    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:injectedJS
                                                      injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                   forMainFrameOnly:NO];
    [contentController addUserScript:userScript];
    [contentController addScriptMessageHandler:self name:@"interceptedRequestHandler"];
  }

  configuration.userContentController = contentController;
  
  // --- Now create the web view ---
  self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
  self.webView.allowsLinkPreview = true;
  self.webView.autoresizingMask =
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.webView.navigationDelegate = self;

  // Add the WKWebView to the view hierarchy
  [self.view addSubview:self.webView];

  [self.webView addObserver:self
                forKeyPath:@"URL"
                  options:NSKeyValueObservingOptionNew
                  context:nil];


  // Set the custom user agent if provided
  if (self.customUserAgent != nil) {
    self.webView.customUserAgent = self.customUserAgent;
  }

  // Load the provided URL, injecting any initial cookies first
  if (self.request) {
    if (self.initialCookies.count > 0) {
      WKHTTPCookieStore *cookieStore = self.websiteDataStore.httpCookieStore;
      dispatch_group_t group = dispatch_group_create();
      for (NSHTTPCookie *cookie in self.initialCookies) {
        dispatch_group_enter(group);
        [cookieStore setCookie:cookie completionHandler:^{ dispatch_group_leave(group); }];
      }
      dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self.webView loadRequest:self.request];
      });
    } else {
      [self.webView loadRequest:self.request];
    }
  }
}

- (NSString *)nextId {
  self.eventCounter += 1;
  return [NSString stringWithFormat:@"%ld", (long)self.eventCounter];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  // Add navigation items after the view hierarchy is fully set up
  if (!self.navigationItem.rightBarButtonItem) {
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                             target:self
                             action:@selector(close)];
    closeButton.accessibilityIdentifier = @"CloseWebView";
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
    NSString *event_id = [self nextId];
    [dict setObject:@"close" forKey:@"event"];
    [dict setObject:event_id forKey:@"id"];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    NSString *payload = [[NSString alloc] initWithData:jsonData
                                              encoding:NSUTF8StringEncoding];

    opacity_core::emit_webview_event([payload UTF8String]);

    if (self.onDismissCallback) {
      self.onDismissCallback();
    }
    self.interceptRequests = false;
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
    @"id" : [self nextId]
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

- (NSString *)evalJs:(NSString *)js timeout:(double)timeoutSeconds {
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
  __block NSString *result = nil;

  // callAsyncJavaScript treats `js` as the body of an async function, so
  // `return`, `await`, and top-level Promises all work without any wrapping.
  // WebKit natively awaits any returned thenable before calling the completion handler,
  // so we don't need a message-handler bridge or a custom JS wrapper.
  WKWebView *webView = self.webView;
  void (^evalBlock)(void) = ^{
    [webView callAsyncJavaScript:js
                       arguments:@{}
                         inFrame:nil
                  inContentWorld:WKContentWorld.pageWorld
               completionHandler:^(id _Nullable jsResult, NSError *_Nullable error) {
      if (error != nil) {
        NSDictionary *errorDict = @{@"error" : error.localizedDescription};
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:errorDict options:0 error:nil];
        result = jsonData ? [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]
                          : @"{\"error\":\"unknown error\"}";
      } else {
        id value = jsResult ?: [NSNull null];
        NSDictionary *resultDict = @{@"result" : value};
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDict options:0 error:nil];
        result = jsonData ? [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]
                          : @"{\"result\":null}";
      }
      dispatch_semaphore_signal(semaphore);
    }];
  };

  if ([NSThread isMainThread]) {
    evalBlock();
  } else {
    dispatch_async(dispatch_get_main_queue(), evalBlock);
  }

  // timeout == 0: fire-and-forget (DISPATCH_TIME_NOW = don't wait, script still runs)
  dispatch_time_t deadline = timeoutSeconds == 0.0
      ? DISPATCH_TIME_NOW
      : dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeoutSeconds * NSEC_PER_SEC));

  BOOL timedOut = dispatch_semaphore_wait(semaphore, deadline) != 0;
  return timedOut ? @"{\"result\":null}" : (result ?: @"{\"result\":null}");
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
                      userAgent:(NSString *)userAgent
              interceptRequests:(bool)interceptRequests
                 initialCookies:(NSArray<NSHTTPCookie *> *)initialCookies {
  self = [super init];

  if (self) {
    _request = request;
    _customUserAgent = userAgent;
    _interceptRequests = interceptRequests;
    _initialCookies = initialCookies;
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
  NSString *event_id = [self nextId];
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
  [dict setObject:[self nextId] forKey:@"id"];
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

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
  if ([message.name isEqualToString:@"renderedHtmlReady"]) {
    NSDictionary *payload = [message.body isKindOfClass:[NSDictionary class]] ? message.body : nil;
    NSString *mapperJson =
        [payload[@"mapper_json"] isKindOfClass:[NSString class]] ? payload[@"mapper_json"] : @"";
    if (mapperJson.length > 0) {
      [self presentGeneratedOverlayWithMapperJson:mapperJson];
    }
    return;
  }

  if (self.interceptRequests && [message.name isEqualToString:@"interceptedRequestHandler"]) {
    NSDictionary *payload = message.body;
    NSString *requestType = payload[@"requestType"];
    NSDictionary *data = payload[@"data"];

    NSDictionary *event = @{
      @"event" : @"intercepted_request",
      @"request_type" : requestType,
      @"data" : data,
      @"id" : [self nextId]
    };

    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:event
                                                       options:0
                                                         error:&error];
    NSString *payloadString = [[NSString alloc] initWithData:jsonData
                                                    encoding:NSUTF8StringEncoding];
    opacity_core::emit_webview_event([payloadString UTF8String]);
  }
}


@end
