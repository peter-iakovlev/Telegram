#import "TGModernConversationGenericEmptyListView.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGWallpaperInfo.h>
#import "TGWallpaperManager.h"

#import "TGPresentation.h"

@interface TGModernConversationGenericEmptyListView ()
{
    UIImageView *_backgroundImageView;
    UIImageView *_iconView;
    UILabel *_titleLabel;
    UIView *_containerView;
}

@end

@implementation TGModernConversationGenericEmptyListView

@synthesize presentation = _presentation;

- (instancetype)initWithFrame:(CGRect)frame presentation:(TGPresentation *)presentation
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 144.0f, 144.0f)];
    if (self)
    {
        _presentation = presentation;
        
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 144.0f, 144.0f)];
        [self addSubview:_containerView];
        
        _backgroundImageView = [[UIImageView alloc] initWithImage:presentation.images.chatPlaceholderBackground];
        _backgroundImageView.frame = _containerView.bounds;
        [_containerView addSubview:_backgroundImageView];
        
        _iconView = [[UIImageView alloc] initWithImage:TGTintedImage(TGImageNamed(@"ModernConversationEmptyListLogo.png"), presentation.pallete.chatSystemTextColor)];
        CGSize iconSize = _iconView.frame.size;
        _iconView.frame = CGRectMake(CGFloor((_containerView.frame.size.width - iconSize.width) / 2.0f), 14.0f, iconSize.width, iconSize.height);
        [_containerView addSubview:_iconView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = presentation.pallete.chatSystemTextColor;
        _titleLabel.font = TGMediumSystemFontOfSize(14.0f);
        
        if ([_titleLabel respondsToSelector:@selector(setAttributedText:)])
        {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:TGLocalized(@"Conversation.EmptyPlaceholder") attributes:nil];
            
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 2;
            style.lineBreakMode = NSLineBreakByWordWrapping;
            style.alignment = NSTextAlignmentCenter;
            [attributedString addAttributes:@{NSParagraphStyleAttributeName: style} range:NSMakeRange(0, attributedString.length)];
            
            _titleLabel.attributedText = attributedString;
        }
        else
            _titleLabel.text = TGLocalized(@"Conversation.EmptyPlaceholder");
        
        
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize labelSize = [_titleLabel sizeThatFits:CGSizeMake(105.0f, CGFLOAT_MAX)];
        _titleLabel.frame = CGRectMake(CGFloor((_containerView.frame.size.width - labelSize.width) / 2.0f), 114.0f - CGFloor(labelSize.height / 2.0f), labelSize.width, labelSize.height);
        [_containerView addSubview:_titleLabel];
        
        self.userInteractionEnabled = false;
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    if (_presentation != presentation)
    {
        _presentation = presentation;
        
        _backgroundImageView.image = presentation.images.chatPlaceholderBackground;
        _iconView.image = TGTintedImage(TGImageNamed(@"ModernConversationEmptyListLogo.png"), presentation.pallete.chatSystemTextColor);
        _titleLabel.textColor = presentation.pallete.chatSystemTextColor;
    }
}

- (void)adjustLayoutForSize:(CGSize)size contentInsets:(UIEdgeInsets)contentInsets duration:(NSTimeInterval)duration curve:(int)curve
{
    [super adjustLayoutForSize:size contentInsets:contentInsets duration:duration curve:curve];
    
    CGSize messageAreaSize = size;
    
    CGRect frame = CGRectMake(CGFloor((messageAreaSize.width - self.frame.size.width) / 2.0f), contentInsets.top + CGFloor((messageAreaSize.height - self.frame.size.height - contentInsets.top - contentInsets.bottom) / 2.0f), self.frame.size.width, self.frame.size.height);;
    CGFloat alpha = messageAreaSize.height - contentInsets.top - contentInsets.bottom < 110 ? 0.0f : 1.0f;
    
    if (duration > DBL_EPSILON)
    {
        [UIView animateWithDuration:duration delay:0 options:curve << 16 animations:^
        {
            self.frame = frame;
            _containerView.alpha = alpha;
        } completion:nil];
    }
    else
    {
        self.frame = frame;
        _containerView.alpha = alpha;
    }
}

@end
