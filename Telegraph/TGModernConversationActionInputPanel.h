/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernConversationInputPanel.h"

@class ASHandle;

typedef enum {
    TGModernConversationActionInputPanelIconNone,
    TGModernConversationActionInputPanelIconJoin
} TGModernConversationActionInputPanelIcon;

@interface TGModernConversationActionInputPanel : TGModernConversationInputPanel

@property (nonatomic, strong) ASHandle *companionHandle;

- (void)setActionWithTitle:(NSString *)title action:(NSString *)action;
- (void)setActionWithTitle:(NSString *)title action:(NSString *)action color:(UIColor *)color;
- (void)setActionWithTitle:(NSString *)title action:(NSString *)action color:(UIColor *)color icon:(TGModernConversationActionInputPanelIcon)icon;
- (void)setActivity:(bool)activity;

@end
