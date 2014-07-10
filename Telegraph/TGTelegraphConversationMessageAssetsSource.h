/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGConversationMessageAssetsSource.h"

extern int TGBaseFontSize;

@interface TGTelegraphConversationMessageAssetsSource : NSObject <TGConversationMessageAssetsSource>

@property (nonatomic) int monochromeColor;
@property (nonatomic) CGFloat systemAlpha;
@property (nonatomic) CGFloat buttonsAlpha;
@property (nonatomic) CGFloat highlighteButtonAlpha;
@property (nonatomic) CGFloat progressAlpha;

+ (TGTelegraphConversationMessageAssetsSource *)instance;

@end
