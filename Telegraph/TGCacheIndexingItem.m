#import "TGCacheIndexingItem.h"

#import "TGCacheIndexingItemView.h"

@implementation TGCacheIndexingItem

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.selectable = false;
    }
    return self;
}

- (Class)itemViewClass {
    return [TGCacheIndexingItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize {
    return CGSizeMake(containerSize.width, 104.0f);
}

@end
