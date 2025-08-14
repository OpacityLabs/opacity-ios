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

void force_symbol_registration();
