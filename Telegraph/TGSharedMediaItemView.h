#import <UIKit/UIKit.h>

#import "TGSharedMediaItem.h"

@class TGSharedMediaImageViewQueue;

@interface TGSharedMediaItemView : UICollectionViewCell

@property (nonatomic, strong) id<TGSharedMediaItem> item;
@property (nonatomic, strong) TGSharedMediaImageViewQueue *imageViewQueue;
@property (nonatomic, copy) bool (^isItemHidden)(id<TGSharedMediaItem>);
@property (nonatomic, copy) bool (^isItemSelected)(id<TGSharedMediaItem>);
@property (nonatomic, copy) void (^toggleItemSelection)(id<TGSharedMediaItem>);
@property (nonatomic, copy) void (^itemLongPressed)(id<TGSharedMediaItem>);
@property (nonatomic) bool editing;

- (void)enqueueImageViewWithUri;
- (UIView *)transitionView;
- (void)updateItemHidden;
- (void)updateItemSelected;
- (void)imageThumbnailUpdated:(NSString *)thumbnaiUri;
- (void)setEditing:(bool)editing animated:(bool)animated;
- (void)setEditing:(bool)editing animated:(bool)animated delay:(NSTimeInterval)delay;

@end
