#import "TGModernCollectionCell.h"

#import "TGMessageModernConversationItem.h"

@interface TGModernCollectionCellLayer : CALayer

@end

@implementation TGModernCollectionCellLayer

- (void)setShouldRasterize:(BOOL)shouldRasterize
{
    if (shouldRasterize)
        [super setShouldRasterize:false];
}

@end

@interface TGModernCollectionCell ()
{
    bool _editing;
}

@end

@implementation TGModernCollectionCell

+ (Class)layerClass
{
    return [TGModernCollectionCellLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.contentView.transform = CGAffineTransformMakeRotation((float)M_PI);
        self.clipsToBounds = true;
    }
    return self;
}

- (void)relativeBoundsUpdated:(CGRect)bounds
{
    id item = _boundItem;
    if (item != nil && [item conformsToProtocol:@protocol(TGModernCollectionRelativeBoundsObserver)])
    {
        CGRect convertedBounds = [self.contentView convertRect:bounds fromView:self];
        
        [item relativeBoundsUpdated:self bounds:convertedBounds];
    }
}

- (void)setEditing:(bool)editing animated:(bool)__unused animated viewStorage:(TGModernViewStorage *)__unused viewStorage
{
    if (_editing != editing)
    {
        _editing = editing;
        self.contentView.userInteractionEnabled = !_editing;
    }
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
}

@end
