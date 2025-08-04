#ifdef __OBJC__
#import <Foundation/Foundation.h>
#else
#ifndef OBJC_EXTERN
#if defined(__cplusplus)
#define OBJC_EXTERN extern "C"
#else
#define OBJC_EXTERN extern
#endif
#endif
#endif

#ifdef __cplusplus
namespace opacity {
#endif

OBJC_EXTERN void ios_prepare_request(const char *url);
OBJC_EXTERN void ios_set_request_header(const char *key, const char *value);
OBJC_EXTERN void ios_present_webview();
OBJC_EXTERN void ios_close_webview();
OBJC_EXTERN void ios_prepare_request_threadsafe(const char *url);
OBJC_EXTERN void ios_set_request_header_threadsafe(const char *key,
                                                   const char *value);
OBJC_EXTERN void ios_present_webview_threadsafe();
OBJC_EXTERN void ios_close_webview_threadsafe();
OBJC_EXTERN const char *ios_get_browser_cookies_for_current_url();
OBJC_EXTERN const char *ios_get_browser_cookies_for_domain(const char *domain);
/**
 * This function is a bit special, it doesn't do anything except force the
 * compiler not to eliminate not used functions In this case ↑ those above,
 * which are used by the Rust SDK. This function needs to be called at
 * initialization.
 */
OBJC_EXTERN void force_symbol_registration();
OBJC_EXTERN void ensure_symbols_loaded();

#ifdef __cplusplus
} // namespace opacity
#endif
