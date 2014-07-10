/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGStaticBackdropAreaData.h"

extern NSString *TGStaticBackdropMessageActionCircle;
extern NSString *TGStaticBackdropMessageTimestamp;
extern NSString *TGStaticBackdropMessageAdditionalData;

@interface TGStaticBackdropImageData : NSObject

- (TGStaticBackdropAreaData *)backdropAreaForKey:(NSString *)key;
- (void)setBackdropArea:(TGStaticBackdropAreaData *)backdropArea forKey:(NSString *)key;

@end
