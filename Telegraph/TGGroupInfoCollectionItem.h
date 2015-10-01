/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionItem.h"

@class TGConversation;
@class ASHandle;

@interface TGGroupInfoCollectionItem : TGCollectionItem

@property (nonatomic, strong) ASHandle *interfaceHandle;

@property (nonatomic) bool editing;
@property (nonatomic) bool isBroadcast;
@property (nonatomic) bool isChannel;

- (void)setConversation:(TGConversation *)conversation;
- (void)setUpdatingTitle:(NSString *)updatingTitle;
- (void)setUpdatingAvatar:(UIImage *)updatingAvatar hasUpdatingAvatar:(bool)hasUpdatingAvatar;
- (bool)hasUpdatingAvatar;
- (void)setStaticAvatar:(UIImage *)staticAvatar;
- (UIImage *)staticAvatar;
- (void)setEditing:(bool)editing animated:(bool)animated;

- (id)avatarView;
- (NSString *)editingTitle;
- (void)copyUpdatingAvatarToCacheWithUri:(NSString *)uri;
- (void)makeNameFieldFirstResponder;

@end
