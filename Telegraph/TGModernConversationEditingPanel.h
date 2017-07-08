/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernConversationInputPanel.h"

@class TGModernConversationEditingPanel;

@protocol TGModernConversationEditingPanelDelegate <TGModernConversationInputPanelDelegate>

- (void)editingPanelRequestedDeleteMessages:(TGModernConversationEditingPanel *)editingPanel;
- (void)editingPanelRequestedForwardMessages:(TGModernConversationEditingPanel *)editingPanel;
- (void)editingPanelRequestedShareMessages:(TGModernConversationEditingPanel *)editingPanel;

@end

@interface TGModernConversationEditingPanel : TGModernConversationInputPanel

- (void)setForwardingEnabled:(bool)forwardingEnabled;
- (void)setDeleteEnabled:(bool)deleteEnabled;
- (void)setShareEnabled:(bool)shareEnabled;
- (void)setActionsEnabled:(bool)actionsEnabled;

@end
