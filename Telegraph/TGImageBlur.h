/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@class TGTemporaryImage;

UIImage *TGAverageColorImage(UIColor *color);
UIImage *TGAverageColorAttachmentImage(UIColor *color);
UIImage *TGTemporaryAttachmentImage(TGTemporaryImage *temporaryImage, CGSize size);
UIImage *TGBlurredAttachmentImage(UIImage *source, CGSize size, uint32_t *averageColor);
UIImage *TGBlurredFileImage(UIImage *source, CGSize size, uint32_t *averageColor);
UIImage *TGLoadedAttachmentImage(UIImage *source, CGSize size, uint32_t *averageColor);
UIImage *TGLoadedFileImage(UIImage *source, CGSize size, uint32_t *averageColor);
UIImage *TGReducedAttachmentImage(UIImage *source, CGSize originalSize);
UIImage *TGBlurredBackgroundImage(UIImage *source, CGSize size);