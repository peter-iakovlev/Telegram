/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionItem.h"

@class TGUser;
@class TGConversation;
@class ASHandle;

@interface TGGroupInfoUserCollectionItem : TGCollectionItem

@property (nonatomic, strong) ASHandle *interfaceHandle;
@property (nonatomic, strong) TGUser *user;
@property (nonatomic, strong) TGConversation *conversation;
@property (nonatomic, strong) NSString *optionTitle;
@property (nonatomic, strong) NSString *customStatus;

- (void)setCanEdit:(bool)canEdit;
- (void)setCanEdit:(bool)canEdit animated:(bool)animated;
- (void)setDisabled:(bool)disabled;

- (void)updateTimestamp;

@end
