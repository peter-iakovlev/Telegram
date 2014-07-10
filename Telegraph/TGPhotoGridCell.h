/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "ASWatcher.h"

@interface TGPhotoGridCell : UITableViewCell

@property (nonatomic) int numberOfImagePlaces;
@property (nonatomic, strong) NSMutableArray *imageUrls;
@property (nonatomic, strong) NSMutableArray *imageTags;
@property (nonatomic, strong) NSMutableArray *imageAttachments;

@property (nonatomic, strong) ASHandle *watcherHandle;

- (void)collectCachedPhotos:(NSMutableDictionary *)dict;

- (CGRect)rectForImageWithTag:(id)tag;
- (UIView *)viewForImageWithTag:(id)tag;

- (void)reloadImagesWithUrl:(NSString *)url;

@end
