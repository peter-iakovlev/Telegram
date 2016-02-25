#import "TGVersionCollectionItem.h"
#import "TGVersionCollectionItemView.h"

@implementation TGVersionCollectionItem

- (instancetype)initWithVersion:(NSString *)version
{
    self = [super init];
    if (self != nil)
    {
        self.transparent = true;
        self.highlightable = false;
        self.selectable = false;
        
        _version = version;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGVersionCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 54);
}

- (void)bindView:(TGVersionCollectionItemView *)view
{
    [super bindView:view];
    
    [view setVersion:_version];
}

- (void)setVersion:(NSString *)version
{
    _version = version;
    
    if (self.view != nil)
        [(TGVersionCollectionItemView *)self.view setVersion:version];
}

@end
