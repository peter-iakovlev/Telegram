#import "TGCollectionItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import <QuartzCore/QuartzCore.h>

#import "TGPresentation.h"

@interface TGCollectionItemView ()
{
}

@end

@implementation TGCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _itemPosition = 1 << 31;
        _separatorInset = 15.0f;
        
        self.backgroundView = [[UIView alloc] init];
        
        self.selectedBackgroundView = [[UIView alloc] init];
        
        if (_topStripeView == nil)
        {
            _topStripeView = [[UIView alloc] init];
            [self.backgroundView addSubview:_topStripeView];
        }
        
        if (_bottomStripeView == nil)
        {
            _bottomStripeView = [[UIView alloc] init];
            [self.backgroundView addSubview:_bottomStripeView];
        }
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _presentation = presentation;
    
    if (!self.boundItem.transparent)
        self.backgroundView.backgroundColor = presentation.pallete.collectionMenuCellBackgroundColor;
    
    self.selectedBackgroundView.backgroundColor = presentation.pallete.collectionMenuCellSelectionColor;
    _topStripeView.backgroundColor = presentation.pallete.collectionMenuSeparatorColor;
    _bottomStripeView.backgroundColor = presentation.pallete.collectionMenuSeparatorColor;
}

- (void)setItemPosition:(int)itemPosition
{
    [self setItemPosition:itemPosition animated:false];
}

- (void)setItemPosition:(int)itemPosition animated:(bool)animated
{
    if (_itemPosition != itemPosition)
    {
        _itemPosition = itemPosition;
        if (animated)
        {
            [UIView animateWithDuration:0.25 animations:^
            {
                [self _updateStripes];
            }];
            [self setNeedsLayout];
        }
        else
        {
            [self _updateStripes];
            [self setNeedsLayout];
        }
    }
}

- (void)setIgnoreSeparatorInset:(bool)ignoreSeparatorInset
{
    _ignoreSeparatorInset = ignoreSeparatorInset;
    [self setNeedsLayout];
}

- (void)_updateStripes
{
    _topStripeView.alpha = (_itemPosition & (TGCollectionItemViewPositionFirstInBlock | TGCollectionItemViewPositionLastInBlock | TGCollectionItemViewPositionMiddleInBlock)) == 0 ? 0.0f : 1.0f;
    _bottomStripeView.alpha = (_itemPosition & (TGCollectionItemViewPositionLastInBlock | TGCollectionItemViewPositionIncludeNextSeparator)) == 0 ? 0.0f : 1.0f;
    self.backgroundView.backgroundColor = _itemPosition == 0 ? [UIColor clearColor] : _presentation.pallete.collectionMenuCellBackgroundColor;
}

static void adjustSelectedBackgroundViewFrame(CGSize viewSize, int positionMask, UIEdgeInsets selectionInsets, UIView *backgroundView)
{
    CGRect frame = backgroundView.frame;
    
    CGFloat stripeHeight = TGScreenPixel;
    
    if ((positionMask & TGCollectionItemViewPositionFirstInBlock) && (positionMask & TGCollectionItemViewPositionLastInBlock))
    {
        frame.origin.y = 0;
        frame.size.height = viewSize.height;
    }
    else if (positionMask & (TGCollectionItemViewPositionLastInBlock | TGCollectionItemViewPositionIncludeNextSeparator))
    {
        frame.origin.y = 0;
        frame.size.height = viewSize.height;
    }
    else if (positionMask & TGCollectionItemViewPositionFirstInBlock)
    {
        frame.origin.y = 0;
        frame.size.height = viewSize.height + stripeHeight;
    }
    else
    {
        frame.origin.y = 0;
        frame.size.height = viewSize.height + stripeHeight;
    }
    
    frame.origin.y -= selectionInsets.top;
    frame.size.height += selectionInsets.top + selectionInsets.bottom;

    backgroundView.frame = frame;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected)
    {
        adjustSelectedBackgroundViewFrame(self.frame.size, _itemPosition, _selectionInsets, self.selectedBackgroundView);
        
        [self adjustOrdering];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted)
    {
        adjustSelectedBackgroundViewFrame(self.frame.size, _itemPosition, _selectionInsets, self.selectedBackgroundView);
        
        [self adjustOrdering];
    }
}

- (void)adjustOrdering
{
    Class UITableViewCellClass = [UICollectionViewCell class];
    Class UISearchBarClass = [UISearchBar class];
    int maxCellIndex = 0;
    int index = -1;
    int selfIndex = 0;
    for (UIView *view in self.superview.subviews)
    {
        index++;
        if ([view isKindOfClass:UITableViewCellClass] || [view isKindOfClass:UISearchBarClass])
        {
            maxCellIndex = index;
            
            if (view == self)
                selfIndex = index;
        }
    }
    
    if (selfIndex < maxCellIndex)
    {
        [self.superview insertSubview:self atIndex:maxCellIndex];
    }
}

- (void)setSafeAreaInset:(UIEdgeInsets)safeAreaInset
{
    _safeAreaInset = safeAreaInset;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize viewSize = self.bounds.size;
    
    adjustSelectedBackgroundViewFrame(viewSize, _itemPosition, _selectionInsets, self.selectedBackgroundView);
    
    static CGFloat stripeHeight = 0.0f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        stripeHeight = TGScreenPixel;
    });
    
    CGFloat separatorInset = !_ignoreSeparatorInset ? _separatorInset + self.safeAreaInset.left : 0.0f;
    
    if (_itemPosition & TGCollectionItemViewPositionFirstInBlock)
        _topStripeView.frame = CGRectMake(0, 0, viewSize.width, stripeHeight);
    else
        _topStripeView.frame = CGRectMake(separatorInset, 0, viewSize.width - separatorInset, stripeHeight);
    
    if (_itemPosition & TGCollectionItemViewPositionLastInBlock)
        _bottomStripeView.frame = CGRectMake(0, viewSize.height - stripeHeight, viewSize.width, stripeHeight);
    else if (_itemPosition & TGCollectionItemViewPositionIncludeNextSeparator)
        _bottomStripeView.frame = CGRectMake(separatorInset, viewSize.height - stripeHeight, viewSize.width - separatorInset, stripeHeight);
}

@end
