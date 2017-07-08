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
@property (nonatomic, strong) NSString *customLabel;
@property (nonatomic) bool displaySwitch;
@property (nonatomic) bool displayCheck;
@property (nonatomic) bool enableSwitch;
@property (nonatomic) bool switchIsOn;
@property (nonatomic) bool checkIsOn;
@property (nonatomic) bool requiresFullSeparator;

@property (nonatomic) bool canPromote;
@property (nonatomic) bool canRestrict;
@property (nonatomic) bool canBan;
@property (nonatomic) bool canDelete;

@property (nonatomic, copy) void (^toggled)(bool value);
@property (nonatomic, copy) void (^pressed)();

@property (nonatomic, copy) void (^requestDelete)();
@property (nonatomic, copy) void (^requestRestrict)();
@property (nonatomic, copy) void (^requestPromote)();

- (void)setCanEdit:(bool)canEdit;
- (void)setCanEdit:(bool)canEdit animated:(bool)animated;
- (void)setDisabled:(bool)disabled;
- (void)setSwitchIsOn:(bool)switchIsOn animated:(bool)animated;

- (void)updateTimestamp;

@end
