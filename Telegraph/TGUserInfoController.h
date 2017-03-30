/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionMenuController.h"

#import "ASWatcher.h"

@class TGUserInfoCollectionItem;

@interface TGUserInfoController : TGCollectionMenuController <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, strong) TGUserInfoCollectionItem *userInfoItem;
@property (nonatomic, strong) TGCollectionMenuSection *callsSection;
@property (nonatomic, strong) TGCollectionMenuSection *usernameSection;
@property (nonatomic, strong) TGCollectionMenuSection *phonesSection;
@property (nonatomic, strong) TGCollectionMenuSection *actionsSection;

@end
