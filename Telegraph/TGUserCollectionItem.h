/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionItem.h"

@class TGUser;
@class ASHandle;

@interface TGUserCollectionItem : TGCollectionItem

@property (nonatomic, strong) ASHandle *interfaceHandle;

@property (nonatomic, strong) NSString *deleteActionTitle;
@property (nonatomic) bool showAvatar;
@property (nonatomic, strong) TGUser *user;

@end
