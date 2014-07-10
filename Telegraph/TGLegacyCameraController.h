/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@protocol TGLegacyCameraControllerDelegate <NSObject>

@optional

- (void)legacyCameraControllerCapturedVideoWithTempFilePath:(NSString *)tempVideoFilePath fileSize:(int32_t)fileSize previewImage:(UIImage *)previewImage duration:(NSTimeInterval)duration dimensions:(CGSize)dimenstions assetUrl:(NSString *)assetUrl;
- (void)legacyCameraControllerCompletedWithExistingMedia:(id)media;
- (void)legacyCameraControllerCompletedWithNoResult;
- (void)legacyCameraControllerCompletedWithDocument:(NSURL *)fileUrl fileName:(NSString *)fileName mimeType:(NSString *)mimeType;

@end

@interface TGLegacyCameraController : UIImagePickerController

@property (nonatomic, weak) id<TGLegacyCameraControllerDelegate> completionDelegate;
@property (nonatomic) bool storeCapturedAssets;
@property (nonatomic) bool isInDocumentMode;
@property (nonatomic) bool avatarMode;

@end
