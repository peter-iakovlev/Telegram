#import "TGChannelModeratorCollectionItem.h"

#import "TGChannelModeratorCollectionItemView.h"

@implementation TGChannelModeratorCollectionItem

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.selectable = false;
        self.highlightable = false;
    }
    return self;
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize {
    return CGSizeMake(containerSize.width, 85.0f);
}

- (Class)itemViewClass {
    return [TGChannelModeratorCollectionItemView class];
}

- (void)bindView:(TGCollectionItemView *)view {
    [super bindView:view];
    
    [((TGChannelModeratorCollectionItemView *)view) setUser:_user];
}

@end
