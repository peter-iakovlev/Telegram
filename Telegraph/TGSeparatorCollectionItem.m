#import "TGSeparatorCollectionItem.h"

#import "TGSeparatorCollectionItemView.h"

@interface TGSeparatorCollectionItem () {
}

@end

@implementation TGSeparatorCollectionItem

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.selectable = false;
        self.highlightable = false;
        self.transparent = true;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGSeparatorCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 9.0f);
}

- (void)bindView:(TGSeparatorCollectionItemView *)view
{
    [super bindView:view];
}


@end

