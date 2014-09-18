#import "TGImageSearchQueryCell.h"

#import "TGImageUtils.h"
#import "TGFont.h"

@interface TGImageSearchQueryCell ()
{
    UIView *_separatorView;
}

@property (nonatomic, strong) UILabel *label;

@end

@implementation TGImageSearchQueryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.superview.clipsToBounds = false;
        
        self.backgroundView = [[UIView alloc] init];
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = TGSelectionColor();
        
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = TGSeparatorColor();
        [self.backgroundView addSubview:_separatorView];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, self.contentView.frame.size.width - 16 - 8, 22)];
        _label.contentMode = UIViewContentModeLeft;
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _label.font = TGSystemFontOfSize(18);
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor blackColor];
        [self.contentView addSubview:_label];
    }
    return self;
}

- (void)setQueryText:(NSString *)queryText
{
    _label.text = queryText;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected)
    {
        CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
        CGRect frame = self.selectedBackgroundView.frame;
        frame.origin.y = -separatorHeight;
        frame.size.height = self.frame.size.height + separatorHeight;
        self.selectedBackgroundView.frame = frame;
        
        [self adjustOrdering];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted)
    {
        CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
        CGRect frame = self.selectedBackgroundView.frame;
        frame.origin.y = -separatorHeight;
        frame.size.height = self.frame.size.height + separatorHeight;
        self.selectedBackgroundView.frame = frame;
        
        [self adjustOrdering];
    }
}

- (void)adjustOrdering
{
    if ([self.superview isKindOfClass:[UITableView class]])
    {
        Class UITableViewCellClass = [UITableViewCell class];
        Class UISearchBarClass = [UISearchBar class];
        int maxCellIndex = 0;
        int index = -1;
        int selfIndex = 0;
        for (UIView *view in self.superview.subviews)
        {
            index++;
            if ([view isKindOfClass:UITableViewCellClass] || [view isKindOfClass:UISearchBarClass] || view.tag == 0x33FC2014)
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
    
    CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
    _separatorView.frame = CGRectMake(15.0f, self.frame.size.height - separatorHeight, self.frame.size.width - 15.0f, separatorHeight);
    
    CGRect frame = self.selectedBackgroundView.frame;
    frame.origin.y = -separatorHeight;
    frame.size.height = self.frame.size.height + separatorHeight;
    self.selectedBackgroundView.frame = frame;
}

@end
