#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "helper_functions.h"
#import "ModalWebViewController.h"
#import "OpacityObjCWrapper.h"
#import "Reachability.h"
#import "sdk.h"

FOUNDATION_EXPORT double OpacityCoreVersionNumber;
FOUNDATION_EXPORT const unsigned char OpacityCoreVersionString[];

