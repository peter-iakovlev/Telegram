#import "TGDisclosureActionCollectionItemView.h"

#import "TGFont.h"
#import "TGImageUtils.h"

@interface TGDisclosureActionCollectionItemView ()
{
    UILabel *_titleLabel;
    UIImageView *_iconView;
    UIImageView *_disclosureIndicator;
    
    UILabel *_badgeLabel;
    UIImageView *_badgeView;
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
    
    [_titleLabel setNeedsDisplay];
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

- (void)setBadge:(NSString *)badge {
    if (badge != nil) {
        if (_badgeLabel == nil) {
            _badgeLabel = [[UILabel alloc] init];
            _badgeLabel.font = TGSystemFontOfSize(14);
            _badgeLabel.backgroundColor = [UIColor clearColor];
            _badgeLabel.textColor = [UIColor whiteColor];
            [self addSubview:_badgeLabel];
            
            static UIImage *badgeImage = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.0f, 20.0f), false, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                CGContextSetFillColorWithColor(context, UIColorRGB(0x0f94f3).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 20.0f, 20.0f));
                
                badgeImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:10.0f topCapHeight:0.0f];
                UIGraphicsEndImageContext();
            });
            _badgeView = [[UIImageView alloc] initWithImage:badgeImage];
            
            [self addSubview:_badgeView];
            [self addSubview:_badgeLabel];
        }
        _badgeLabel.text = badge;
        [_badgeLabel sizeToFit];
    } else {
        [_badgeView removeFromSuperview];
        _badgeView = nil;
        [_badgeLabel removeFromSuperview];
        _badgeLabel = nil;
    }
    
    [self setNeedsLayout];
}

- (void)setHideArrow:(bool)hideArrow {
    _disclosureIndicator.hidden = hideArrow;
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
    
    if (_badgeLabel != nil) {
        CGSize labelSize = _badgeLabel.frame.size;
        CGFloat badgeWidth = MAX(20.0f, labelSize.width + 8.0);
        _badgeView.frame = CGRectMake((_disclosureIndicator.hidden ? bounds.size.width : CGRectGetMinX(_disclosureIndicator.frame)) - 10.0 - badgeWidth, CGFloor((bounds.size.height - 20.0f) / 2.0f), badgeWidth, 20.0f);
        _badgeLabel.frame = CGRectMake(CGRectGetMinX(_badgeView.frame) + TGRetinaFloor((badgeWidth - labelSize.width) / 2.0f), CGRectGetMinY(_badgeView.frame) + 1.0f, labelSize.width, labelSize.height);
    }
}

@end
