/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGImagePickerAsset.h"
#import "TGImageInfo.h"

@class TGImagePickerCell;

@protocol TGImagePickerCellDelegate <NSObject>

- (void)imagePickerCell:(TGImagePickerCell *)cell selectedSearchId:(int)searchId imageInfo:(TGImageInfo *)imageInfo;
- (void)imagePickerCell:(TGImagePickerCell *)cell tappedSearchId:(int)searchId imageInfo:(TGImageInfo *)imageInfo thumbnailImage:(UIImage *)thumbnailImage;

@end

@interface TGImagePickerCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier selectionControls:(bool)selectionControls imageSize:(float)imageSize;

- (void)resetImages:(int)imagesInRow imageSize:(CGFloat)imageSize inset:(CGFloat)inset;
- (void)addAsset:(TGImagePickerAsset *)asset isSelected:(bool)isSelected withImage:(UIImage *)image;
- (void)addImage:(TGImageInfo *)imageInfo searchId:(int)searchId isSelected:(bool)isSelected;

- (void)animateImageSelected:(id)itemId isSelected:(bool)isSelected;
- (void)updateImageSelected:(id)itemId isSelected:(bool)isSelected;

- (NSString *)assetUrlAtPoint:(CGPoint)point;
- (CGRect)rectForAsset:(NSString *)assetUrl;
- (CGRect)rectForSearchId:(int)searchId;
- (UIView *)hideImage:(id)itemId hide:(bool)hide;

- (UIImage *)imageForSearchId:(int)searchId;
- (NSString *)currentImageUrlForSearchId:(int)searchId;

@end
