#import <Foundation/Foundation.h>

#import "TGModernGalleryDefaultFooterView.h"

@protocol TGModernGalleryItem;

@interface TGModernGalleryModel : NSObject

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong, readonly) id<TGModernGalleryItem> focusItem;

@property (nonatomic, copy) void (^itemsUpdated)(id<TGModernGalleryItem>);
@property (nonatomic, copy) void (^focusOnItem)(id<TGModernGalleryItem>);

- (void)_replaceItems:(NSArray *)items focusingOnItem:(id<TGModernGalleryItem>)item;
- (void)_focusOnItem:(id<TGModernGalleryItem>)item;

- (Class<TGModernGalleryDefaultFooterView>)defaultFooterViewClass;

@end
