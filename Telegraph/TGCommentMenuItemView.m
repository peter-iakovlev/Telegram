#import "TGCommentMenuItemView.h"

#import "TGImageUtils.h"

@interface TGCommentMenuItemView ()

@property (nonatomic, strong) UILabel *labelView;

@end

@implementation TGCommentMenuItemView

+ (UIFont *)defaultFont
{
    static UIFont *font = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        font = [UIFont systemFontOfSize:14.0f];
    });
    return font;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = nil;
        self.opaque = false;
        
        _labelView = [[UILabel alloc] initWithFrame:CGRectMake(1, 7, self.contentView.frame.size.width - 2, self.contentView.frame.size.height - 14)];
        _labelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _labelView.contentMode = UIViewContentModeCenter;
        _labelView.textAlignment = NSTextAlignmentCenter;
        _labelView.font = [TGCommentMenuItemView defaultFont];
        _labelView.backgroundColor = [UIColor clearColor];
        _labelView.textColor = UIColorRGB(0x697487);
        _labelView.shadowColor = UIColorRGB(0xdae0e8);
        _labelView.shadowOffset = CGSizeMake(0, 1);
        _labelView.lineBreakMode = NSLineBreakByWordWrapping;
        _labelView.numberOfLines = 0;
        [self.contentView addSubview:_labelView];
    }
    return self;
}

- (void)setLabel:(NSString *)label
{
    _label = label;
    
    _labelView.text = label;
}

@end
