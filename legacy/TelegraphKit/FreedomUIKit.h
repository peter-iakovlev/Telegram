/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Ernesto Guevara, 2013.
 */

#ifndef FreedomUIKit_h
#define FreedomUIKit_h

#import "Freedom.h"

#ifdef __cplusplus
extern "C" {
#endif
    
void freedomUIKitInit();

bool freedomUIKitTest3();
bool freedomUIKitTest3_1();
void freedomUIKitTest4(dispatch_block_t);
void freedomUIKitTest4_1();
    
@interface FFNotificationCenter : NSNotificationCenter

+ (void)setShouldRotateBlock:(bool (^)())block;

@end
    
#ifdef __cplusplus
}
#endif

#endif
