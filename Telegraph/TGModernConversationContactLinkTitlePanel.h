/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernConversationTitlePanel.h"

@class TGModernConversationContactLinkTitlePanel;

@protocol TGModernConversationContactLinkTitlePanelDelegate <NSObject>

@optional

- (void)contactLinkTitlePanelShareContactPressed:(TGModernConversationContactLinkTitlePanel *)panel;
- (void)contactLinkTitlePanelAddContactPressed:(TGModernConversationContactLinkTitlePanel *)panel;
- (void)contactLinkTitlePanelDismissed:(TGModernConversationContactLinkTitlePanel *)panel;

@end

@interface TGModernConversationContactLinkTitlePanel : TGModernConversationTitlePanel

@property (nonatomic, weak) id<TGModernConversationContactLinkTitlePanelDelegate> delegate;

- (void)setShareContact:(bool)shareContact;
- (bool)shareContact;

@end
