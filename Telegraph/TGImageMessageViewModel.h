/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMessageViewModel.h"

@class TGImageInfo;
@class TGUser;
@class TGModernViewContext;

@class TGModernButtonViewModel;
@class TGMessageImageViewModel;

@interface TGImageMessageViewModel : TGMessageViewModel

@property (nonatomic, strong) TGMessageImageViewModel *imageModel;

- (instancetype)initWithMessage:(TGMessage *)message imageInfo:(TGImageInfo *)imageInfo author:(TGUser *)author context:(TGModernViewContext *)context;

+ (void)calculateImageSizesForImageSize:(in CGSize)imageSize thumbnailSize:(out CGSize *)thumbnailSize renderSize:(out CGSize *)renderSize;

- (void)updateImageInfo:(TGImageInfo *)imageInfo;

- (UIImage *)dateBackground;
- (UIColor *)dateColor;
- (UIImage *)checkPartialImage;
- (UIImage *)checkCompleteImage;
- (int)clockProgressType;
- (CGPoint)dateOffset;
- (NSString *)filterForMessage:(TGMessage *)message imageSize:(CGSize)imageSize sourceSize:(CGSize)sourceSize;
- (CGSize)minimumImageSizeForMessage:(TGMessage *)message;
- (bool)instantPreviewGesture;
- (void)activateMedia;
- (int)defaultOverlayActionType;

- (void)enableInstantPreview;

@end
