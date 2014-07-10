/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGEditableCollectionItemView.h"

@class TGUserInfoEditingPhoneCollectionItemView;

@protocol TGUserInfoEditingPhoneCollectionItemViewDelegate <NSObject>

@optional

- (void)editingPhoneItemViewPhoneChanged:(TGUserInfoEditingPhoneCollectionItemView *)editingPhoneItemView phone:(NSString *)phone;
- (void)editingPhoneItemViewRequestedDelete:(TGUserInfoEditingPhoneCollectionItemView *)editingPhoneItemView;
- (void)editingPhoneItemViewLabelPressed:(TGUserInfoEditingPhoneCollectionItemView *)editingPhoneItemView;

@end

@interface TGUserInfoEditingPhoneCollectionItemView : TGEditableCollectionItemView

@property (nonatomic, weak) id<TGUserInfoEditingPhoneCollectionItemViewDelegate> delegate;

- (void)setLabel:(NSString *)label;
- (void)setPhone:(NSString *)phone;

- (void)makePhoneFieldFirstResponder;

@end
