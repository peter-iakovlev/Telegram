/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionItem.h"

@interface TGUserInfoPhoneCollectionItem : TGCollectionItem

@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) UIColor *phoneColor;
@property (nonatomic) bool lastInList;

@property (nonatomic, assign) bool checking;
@property (nonatomic, assign) bool isChecked;
@property (nonatomic, copy) void (^isCheckedChanged)(bool);

@property (nonatomic, assign) int64_t uniqueId;

- (instancetype)initWithLabel:(NSString *)label phone:(NSString *)phone phoneColor:(UIColor *)phoneColor action:(SEL)action;
- (instancetype)initWithLabel:(NSString *)label phone:(NSString *)phone formattedPhone:(NSString *)formattedPhone phoneColor:(UIColor *)phoneColor action:(SEL)action;

@end
