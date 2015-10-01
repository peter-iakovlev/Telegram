/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionItemView.h"

@class TGGroupInfoCollectionItemView;

@protocol TGGroupInfoCollectionItemViewDelegate <NSObject>

@optional

- (void)groupInfoViewHasTappedAvatar:(TGGroupInfoCollectionItemView *)groupInfoView;
- (void)groupInfoViewHasChangedEditedTitle:(TGGroupInfoCollectionItemView *)groupInfoView title:(NSString *)title;

@end

@interface TGGroupInfoCollectionItemView : TGCollectionItemView

@property (nonatomic, weak) id<TGGroupInfoCollectionItemViewDelegate> delegate;
@property (nonatomic) bool isBroadcast;
@property (nonatomic) bool isChannel;
@property (nonatomic) bool isVerified;

- (id)avatarView;

- (void)setGroupId:(int64_t)groupId;
- (void)setAvatarUri:(NSString *)avatarUri animated:(bool)animated;
- (void)setAvatarImage:(UIImage *)avatarImage animated:(bool)animated;
- (void)setTitle:(NSString *)title;
- (void)setUpdatingTitle:(bool)updatingTitle animated:(bool)animated;
- (void)setUpdatingAvatar:(bool)updatingAvatar animated:(bool)animated;
- (void)setEditing:(bool)editing animated:(bool)animated;

- (void)makeNameFieldFirstResponder;

@end
