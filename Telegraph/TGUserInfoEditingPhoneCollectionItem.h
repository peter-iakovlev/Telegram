/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionItem.h"

@class TGUserInfoEditingPhoneCollectionItem;

@protocol TGUserInfoEditingPhoneCollectionItemDelegate <NSObject>

@optional

- (void)editingPhoneItemRequestedDelete:(TGUserInfoEditingPhoneCollectionItem *)editingPhoneItem;
- (void)editingPhoneItemRequestedLabelSelection:(TGUserInfoEditingPhoneCollectionItem *)editingPhoneItem;

@end

@interface TGUserInfoEditingPhoneCollectionItem : TGCollectionItem

@property (nonatomic, weak) id<TGUserInfoEditingPhoneCollectionItemDelegate> delegate;

@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *phone;

- (void)makePhoneFieldFirstResponder;

@end
