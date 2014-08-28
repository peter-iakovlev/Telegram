/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGEditableCollectionItemView.h"

@class TGGroupInfoUserCollectionItemView;

@protocol TGGroupInfoUserCollectionItemViewDelegate <NSObject>

@optional

- (void)groupInfoUserItemViewRequestedDeleteAction:(TGGroupInfoUserCollectionItemView *)groupInfoUserItemView;

@end

@interface TGGroupInfoUserCollectionItemView : TGEditableCollectionItemView

@property (nonatomic, weak) id<TGGroupInfoUserCollectionItemViewDelegate> delegate;

- (void)setFirstName:(NSString *)firstName lastName:(NSString *)lastName uidForPlaceholderCalculation:(int32_t)uidForPlaceholderCalculation;
- (void)setStatus:(NSString *)status active:(bool)active;
- (void)setAvatarUri:(NSString *)avatarUri;
- (void)setIsSecretChat:(bool)isSecretChat;

- (void)setDisabled:(bool)disabled animated:(bool)animated;

@end
