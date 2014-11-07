/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGEditableCollectionItemView.h"

@class TGUserCollectionItemView;

@protocol TGUserCollectionItemViewDelegate <NSObject>

@optional

- (void)userCollectionItemViewRequestedDeleteAction:(TGUserCollectionItemView *)userCollectionItemView;

@end

@interface TGUserCollectionItemView : TGEditableCollectionItemView

@property (nonatomic, weak) id<TGUserCollectionItemViewDelegate> delegate;

- (void)setShowAvatar:(bool)setShowAvatar;
- (void)setFirstName:(NSString *)firstName lastName:(NSString *)lastName uidForPlaceholderCalculation:(int32_t)uidForPlaceholderCalculation avatarUri:(NSString *)avatarUri;

@end
