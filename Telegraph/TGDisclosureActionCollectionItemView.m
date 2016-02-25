#import "TGDisclosureActionCollectionItemView.h"

#import "TGFont.h"

@interface TGDisclosureActionCollectionItemView ()
{
    UILabel *_titleLabel;
    UIImageView *_iconView;
    UIImageView *_disclosureIndicator;
}

@end

@implementation TGDisclosureActionCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGSystemFontOfSize(17);
        [self addSubview:_titleLabel];
        
        _disclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernListsDisclosureIndicator.png"]];
        [self addSubview:_disclosureIndicator];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
    
    [self setNeedsLayout];
}

- (void)setIcon:(UIImage *)icon
{
    if (_iconView == nil && icon != nil)
    {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (self.frame.size.height - 15) / 2, 29, 29)];
        _iconView.contentMode = UIViewContentModeCenter;
        [self addSubview:_iconView];
    }
    
    _iconView.image = icon;
    self.separatorInset = (icon != nil) ? 59.0f : 15.0f;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat startingX = (_iconView.image != nil) ? 59.0f : 15.0f;
    _titleLabel.frame = CGRectMake(startingX, CGFloor((bounds.size.height - 26) / 2), bounds.size.width - 15 - 40, 26);
    _disclosureIndicator.frame = CGRectMake(bounds.size.width- _disclosureIndicator.frame.size.width - 15, CGFloor((bounds.size.height - _disclosureIndicator.frame.size.height) / 2), _disclosureIndicator.frame.size.width, _disclosureIndicator.frame.size.height);
    
    if (_iconView.image != nil)
    {
        _iconView.frame = CGRectMake(_iconView.frame.origin.x, (self.frame.size.height - _iconView.frame.size.height) / 2, _iconView.frame.size.width, _iconView.frame.size.height);
    }
}

@end
