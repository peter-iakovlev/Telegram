/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGLetteredAvatarView.h"
#import "TGModernView.h"

@interface TGModernLetteredAvatarView : TGLetteredAvatarView <TGModernView>

- (void)setAvatarUri:(NSString *)avatarUri filter:(NSString *)filter placeholder:(UIImage *)placeholder;
- (void)setFirstName:(NSString *)firstName lastName:(NSString *)lastName uid:(int32_t)uid placeholder:(UIImage *)placeholder;
- (void)setTitle:(NSString *)title groupId:(int64_t)groupId placeholder:(UIImage *)placeholder;

@end
