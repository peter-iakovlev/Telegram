#import <Foundation/Foundation.h>

#import "TGModernMediaListItem.h"

@class TGModernGalleryController;

@interface TGModernMediaListModel : NSObject

@property (nonatomic, copy) void (^itemsUpdated)();
@property (nonatomic, copy) void (^itemUpdated)(id<TGModernMediaListItem>);

@property (nonatomic, readonly) NSUInteger totalCount;
@property (nonatomic, strong, readonly) NSArray *items;

- (void)_replaceItems:(NSArray *)items totalCount:(NSUInteger)totalCount;
- (void)_transitionCompleted;

- (TGModernGalleryController *)createGalleryControllerForItem:(id<TGModernMediaListItem>)item hideItem:(void (^)(id<TGModernMediaListItem>))hideItem referenceViewForItem:(UIView *(^)(id<TGModernMediaListItem>))referenceViewForItem;

@end
