/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@class TGImageLuminanceMap;
@class TGStaticBackdropImageData;

@interface UIImage (TG)

- (NSDictionary *)attachmentsDictionary;
- (void)setAttachmentsFromDictionary:(NSDictionary *)attachmentsDictionary;

- (TGStaticBackdropImageData *)staticBackdropImageData;
- (void)setStaticBackdropImageData:(TGStaticBackdropImageData *)staticBackdropImageData;

- (UIEdgeInsets)extendedEdgeInsets;
- (void)setExtendedEdgeInsets:(UIEdgeInsets)edgeInsets;

@end
