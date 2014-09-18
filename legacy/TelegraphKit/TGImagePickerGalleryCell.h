/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@interface TGImagePickerGalleryCell : UITableViewCell

- (void)setIcon:(UIImage *)icon icon2:(UIImage *)icon2 icon3:(UIImage *)icon3;
- (void)setTitle:(NSString *)title countString:(NSString *)countString;
- (void)setTitleAccentColor:(bool)accent;

@end
