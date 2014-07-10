#import "TGGroupedCell.h"

static inline CGRect extendBackgroundSize(CGRect frame, int position)
{
    if (position == 0)
    {
        frame.size.height += 1;
    }
    else if (position == TGGroupedCellPositionFirst)
    {
        frame.size.height += 1;
    }
    
    return frame;
}

@implementation TGGroupedCell

@synthesize extendSelectedBackground = _extendSelectedBackground;
@synthesize groupedCellPosition = _groupedCellPosition;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = nil;
        self.opaque = false;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected)
    {
        CGRect frame = self.selectedBackgroundView.frame;
        frame.origin.y = 0;
        frame.size.height = self.frame.size.height;
        
        if (_extendSelectedBackground)
            self.selectedBackgroundView.frame = extendBackgroundSize(frame, _groupedCellPosition);
        
        [self adjustOrdering];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted)
    {
        CGRect frame = self.selectedBackgroundView.frame;
        frame.origin.y = 0;
        frame.size.height = self.frame.size.height;
        
        if (_extendSelectedBackground)
            self.selectedBackgroundView.frame = extendBackgroundSize(frame, _groupedCellPosition);
        
        [self adjustOrdering];
    }
}

- (void)setExtendSelectedBackground:(bool)extendSelectedBackground
{
    if (_extendSelectedBackground != extendSelectedBackground)
    {
        _extendSelectedBackground = extendSelectedBackground;
        
        if (self.selected || self.highlighted)
        {
            CGRect frame = self.selectedBackgroundView.frame;
            frame.origin.y = 0;
            frame.size.height = self.frame.size.height;
            
            if (_extendSelectedBackground)
                self.selectedBackgroundView.frame = extendBackgroundSize(frame, _groupedCellPosition);
            
            [self adjustOrdering];
        }
    }
}

- (void)adjustOrdering
{
    if ([self.superview isKindOfClass:[UITableView class]])
    {
        Class UITableViewCellClass = [UITableViewCell class];
        int maxCellIndex = 0;
        int index = -1;
        int selfIndex = 0;
        for (UIView *view in self.superview.subviews)
        {
            index++;
            if ([view isKindOfClass:UITableViewCellClass])
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
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.selectedBackgroundView.frame;
    frame.origin.y = 0;
    frame.size.height = self.frame.size.height;
    
    if (_extendSelectedBackground)
        self.selectedBackgroundView.frame = extendBackgroundSize(frame, _groupedCellPosition);
}

@end
