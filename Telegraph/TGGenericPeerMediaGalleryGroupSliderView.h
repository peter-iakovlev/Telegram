#import <UIKit/UIKit.h>

#import "TGGenericPeerGalleryItem.h"

@class TGGenericPeerGalleryGroupItem;

@interface TGGenericPeerMediaGalleryGroupSliderView : UIView

@property (nonatomic, copy) void (^itemChanged)(TGGenericPeerGalleryGroupItem *, bool);

- (void)setGroupedId:(int64_t)groupedId items:(NSArray *)items;
- (void)setCurrentItemKey:(int64_t)key animated:(bool)animated;
- (void)setTransitionProgress:(CGFloat)progress;

@end
