#import "TGLabelMenuItemView.h"

#import "TGInterfaceAssets.h"

@interface TGLabelMenuItemView ()

@property (nonatomic, strong) UILabel *labelView;
@property (nonatomic, strong) UILabel *titleView;

@end

@implementation TGLabelMenuItemView

@synthesize itemTag = _itemTag;

@synthesize title = _title;
@synthesize label = _label;
@synthesize color = _color;

@synthesize labelView = _labelView;
@synthesize titleView = _titleView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _titleView = [[UILabel alloc] initWithFrame:CGRectMake(11, 12, 96, 20)];
        _titleView.font = [UIFont boldSystemFontOfSize:16];
        _titleView.backgroundColor = [UIColor whiteColor];
        _titleView.textColor = [UIColor blackColor];
        _titleView.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:_titleView];
        
        _labelView = [[UILabel alloc] initWithFrame:CGRectMake(11, 12, self.contentView.frame.size.width - 24, 20)];
        _labelView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _labelView.contentMode = UIViewContentModeLeft;
        _labelView.textAlignment = NSTextAlignmentLeft;
        _labelView.font = [UIFont systemFontOfSize:17];
        _labelView.backgroundColor = [UIColor whiteColor];
        _labelView.textColor = UIColorRGB(0x516691);
        _labelView.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:_labelView];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    if (title == nil)
    {
        _titleView.hidden = true;
        _labelView.frame = CGRectMake(11, 12, self.contentView.frame.size.width - 24, 20);
    }
    else
    {
        _titleView.text = title;
        _titleView.hidden = false;
        _labelView.frame = CGRectMake(11 + 96 + 2, 12, self.contentView.frame.size.width - 24 - 96 - 2, 20);
    }
}

- (void)setLabel:(NSString *)label
{
    _label = label;
    _labelView.text = label;
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    _labelView.textColor = color == nil ? UIColorRGB(0x516691) : color;
}

@end
