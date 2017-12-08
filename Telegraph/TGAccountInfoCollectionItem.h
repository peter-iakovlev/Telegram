/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGUserInfoCollectionItem.h"

@interface TGAccountInfoCollectionItem : TGUserInfoCollectionItem

@property (nonatomic, assign) bool hasDisclosureIndicator;
@property (nonatomic, assign) bool showCameraIcon;
@property (nonatomic) SEL action;

- (void)setPhoneNumber:(NSString *)phoneNumber;
- (void)setUsername:(NSString *)username;

- (void)setStatus:(NSString *)status active:(bool)active;
- (void)localizationUpdated;

@end
