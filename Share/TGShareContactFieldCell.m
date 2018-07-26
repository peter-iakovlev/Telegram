#import "TGShareContactFieldCell.h"
#import "TGShareCheckButtonView.h"

#import <LegacyDatabase/LegacyDatabase.h>

@interface TGShareContactFieldCell ()
{
    TGCheckButtonView *_checkButton;
    UILabel *_label;
    UILabel *_value;
}
@end

@implementation TGShareContactFieldCell

@dynamic checked;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
        
        _checkButton = [[TGCheckButtonView alloc] initWithStyle:TGCheckButtonStyleDefaultBlue];
        _checkButton.userInteractionEnabled = false;
        [self addSubview:_checkButton];
        
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:14];
        _label.textColor = [UIColor blackColor];
        [self addSubview:_label];
        
        _value = [[UILabel alloc] init];
        _value.font = [UIFont systemFontOfSize:17];
        _value.textColor = [UIColor hexColor:0x007ee5];
        [self addSubview:_value];
    }
    return self;
}

- (void)setLabel:(NSString *)label value:(NSString *)value
{
    _label.text = label;
    [_label sizeToFit];
    
    _value.text = value;
    if ([value rangeOfString:@"\n"].location != NSNotFound) {
        _value.numberOfLines = 0;
        _value.lineBreakMode = NSLineBreakByWordWrapping;
    } else {
        _value.numberOfLines = 1;
        _value.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    [_value sizeToFit];
    [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)__unused highlighted
{
}

- (void)setHighlighted:(BOOL)__unused highlighted animated:(BOOL)__unused animated
{
}

- (void)setSelected:(BOOL)__unused selected
{
}

- (void)setSelected:(BOOL)__unused selected animated:(BOOL)__unused animated
{
}

- (bool)checked
{
    return _checkButton.selected;
}

- (void)setChecked:(bool)checked
{
    [self setChecked:checked animated:false];
}

- (void)setChecked:(bool)checked animated:(bool)animated
{
    [_checkButton setSelected:checked animated:animated];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _checkButton.frame = CGRectMake(14.0f, floor((self.frame.size.height - _checkButton.frame.size.height) / 2.0f), _checkButton.frame.size.width, _checkButton.frame.size.height);
    
    _label.frame = CGRectMake(60.0f, 11.0f, self.frame.size.width - 60.0f - 10.0f, _label.frame.size.height);
    _value.frame = CGRectMake(60.0f, 30.0f, self.frame.size.width - 60.0f - 10.0f, _value.frame.size.height);
}

@end
