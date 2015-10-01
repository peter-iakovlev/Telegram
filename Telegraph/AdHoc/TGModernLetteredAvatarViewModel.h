/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernViewModel.h"

@interface TGModernLetteredAvatarViewModel : TGModernViewModel

- (instancetype)initWithSize:(CGSize)size placeholder:(UIImage *)placeholder;

- (void)setAvatarUri:(NSString *)avatarUri;
- (void)setAvatarFirstName:(NSString *)firstName lastName:(NSString *)lastName uid:(int32_t)uid;
- (void)setAvatarTitle:(NSString *)title groupId:(int64_t)groupId;

@end
