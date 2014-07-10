#import "TGBroadcastConversationCell.h"

#import "TGLetteredAvatarView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

@interface TGBroadcastConversationCell ()
{
    CALayer *_separatorLayer;
    TGLetteredAvatarView *_avatarView;
    UIImageView *_avatarIconView;
    
    UILabel *_titleLabel;
    UILabel *_statusLabel;
}

@end

@implementation TGBroadcastConversationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        _separatorLayer = [[CALayer alloc] init];
        _separatorLayer.backgroundColor = TGSeparatorColor().CGColor;
        [self.layer addSublayer:_separatorLayer];
        
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(14.0f, 6.0f, 40.0f, 40.0f)];
        [self.contentView addSubview:_avatarView];
        
        _avatarIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BroadcastAvatarIcon.png"]];
        _avatarIconView.frame = (CGRect){{22.0f, 16.0f + TGRetinaPixel}, _avatarIconView.frame.size};
        [self.contentView addSubview:_avatarIconView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGMediumSystemFontOfSize(16.0f);
        _titleLabel.text = @" ";
        [_titleLabel sizeToFit];
        [self.contentView addSubview:_titleLabel];
        
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.textColor = UIColorRGB(0x999999);
        _statusLabel.font = TGSystemFontOfSize(14.0f);
        _statusLabel.text = @" ";
        [_statusLabel sizeToFit];
        [self.contentView addSubview:_statusLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    bool wasSelected = self.selected;
    
    [super setSelected:selected animated:animated];
    
    if ((selected && !wasSelected))
    {
        [self adjustOrdering];
    }
    
    if ((selected && !wasSelected) || (!selected && wasSelected))
    {
        UIView *selectedView = self.selectedBackgroundView;
        if (selectedView != nil && (self.selected || self.highlighted))
        {
            CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
            selectedView.frame = CGRectMake(0, -separatorHeight, selectedView.frame.size.width, self.frame.size.height + separatorHeight);
        }
        
        if (TGIsPad())
        {
            bool hidden = (self.selected || self.highlighted);
            if (_separatorLayer.hidden != hidden)
            {
                [CATransaction begin];
                [CATransaction setDisableActions:true];
                _separatorLayer.hidden = hidden;
                [CATransaction commit];
            }
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    bool wasHighlighted = self.highlighted;
    
    [super setHighlighted:highlighted animated:animated];
    
    if ((highlighted && !wasHighlighted))
    {
        [self adjustOrdering];
    }
    
    if ((highlighted && !wasHighlighted) || (!highlighted && wasHighlighted))
    {
        UIView *selectedView = self.selectedBackgroundView;
        if (selectedView != nil && (self.selected || self.highlighted))
        {
            CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
            selectedView.frame = CGRectMake(0, -separatorHeight, selectedView.frame.size.width, self.frame.size.height + separatorHeight);
        }
        
        if (TGIsPad())
        {
            bool hidden = (self.selected || self.highlighted);
            if (_separatorLayer.hidden != hidden)
            {
                [CATransaction begin];
                [CATransaction setDisableActions:true];
                _separatorLayer.hidden = hidden;
                [CATransaction commit];
            }
        }
    }
}

- (void)adjustOrdering
{
    UIView *selectedView = self.selectedBackgroundView;
    if (selectedView != nil)
    {
        CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
        selectedView.frame = CGRectMake(0, -separatorHeight, selectedView.frame.size.width, self.frame.size.height + separatorHeight);
    }
    
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
}

- (void)setConversationId:(int64_t)conversationId
{
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(40.0f, 40.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //!placeholder
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 40.0f, 40.0f));
        CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, 39.0f, 39.0f));
        
        placeholder = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });

    [_avatarView loadGroupPlaceholderWithSize:CGSizeMake(40.0f, 40.0f) conversationId:conversationId title:@" " placeholder:placeholder];
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)setStatus:(NSString *)status
{
    _statusLabel.text = status;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = self.frame.size;
    
    CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
    _separatorLayer.frame = CGRectMake(65.0f, size.height - separatorHeight, size.width - 65.0f, separatorHeight);
    
    _titleLabel.frame = CGRectMake(67.0f, 7.0f, size.width - 67.0f - 8.0f, _titleLabel.frame.size.height);
    _statusLabel.frame = CGRectMake(67.0f, 29.0f - TGRetinaPixel, size.width - 67.0f - 8.0f, _statusLabel.frame.size.height);
}

@end
