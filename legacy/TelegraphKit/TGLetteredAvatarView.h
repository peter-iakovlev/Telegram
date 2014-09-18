/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGRemoteImageView.h"

@interface TGLetteredAvatarView : TGRemoteImageView

- (void)setSingleFontSize:(CGFloat)singleFontSize doubleFontSize:(CGFloat)doubleFontSize useBoldFont:(bool)useBoldFont;

- (void)setFirstName:(NSString *)firstName lastName:(NSString *)lastName;
- (void)setTitle:(NSString *)title;

- (void)setTitleNeedsDisplay;

- (void)loadUserPlaceholderWithSize:(CGSize)size uid:(int)uid firstName:(NSString *)firstName lastName:(NSString *)lastName placeholder:(UIImage *)placeholder;
- (void)loadGroupPlaceholderWithSize:(CGSize)size conversationId:(int64_t)conversationId title:(NSString *)title placeholder:(UIImage *)placeholder;

@end
