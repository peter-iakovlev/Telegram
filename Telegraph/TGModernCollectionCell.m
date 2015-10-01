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
    UIView *_contentViewForBinding;
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
        [self contentViewForBinding].transform = CGAffineTransformMakeRotation((float)M_PI);
        self.clipsToBounds = true;
        
        _contentViewForBinding = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, frame.size}];
        _contentViewForBinding.transform = CGAffineTransformMakeRotation((float)M_PI);
        [self addSubview:_contentViewForBinding];
    }
    return self;
}

- (void)relativeBoundsUpdated:(CGRect)bounds
{
    id item = _boundItem;
    if (item != nil && [item conformsToProtocol:@protocol(TGModernCollectionRelativeBoundsObserver)])
    {
        CGRect convertedBounds = [[self contentViewForBinding] convertRect:bounds fromView:self];
        
        [item relativeBoundsUpdated:self bounds:convertedBounds];
    }
}

- (void)setEditing:(bool)editing animated:(bool)__unused animated viewStorage:(TGModernViewStorage *)__unused viewStorage
{
    if (_editing != editing)
    {
        _editing = editing;
        [self contentViewForBinding].userInteractionEnabled = !_editing;
    }
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _contentViewForBinding.frame = (CGRect){CGPointZero, frame.size};
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    _contentViewForBinding.frame = (CGRect){CGPointZero, bounds.size};
}

- (UIView *)contentViewForBinding
{
    return _contentViewForBinding;
}

@end
