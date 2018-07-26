#import "TGSecretConversationEmptyListView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGWallpaperManager.h"
#import <LegacyComponents/TGWallpaperInfo.h>

#import "TGPresentationAssets.h"
#import "TGPresentation.h"

@interface TGSecretConversationEmptyListView ()
{
    UIImageView *_backgroundImageView;
    UILabel *_titleLabel;
    UILabel *_secondTitleLabel;
    NSMutableArray *_iconViews;
    NSMutableArray *_labels;
    UIView *_containerView;
}

@end

@implementation TGSecretConversationEmptyListView

@synthesize presentation = _presentation;

- (instancetype)initWithIncoming:(bool)incoming userName:(NSString *)userName presentation:(TGPresentation *)presentation
{
    static const CGFloat minWidth = 236.0f;
    
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, minWidth, 185.0f)];
    if (self)
    {
        _presentation = presentation;
        
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, minWidth, 185.0f)];
        [self addSubview:_containerView];
        
        _backgroundImageView = [[UIImageView alloc] initWithImage:presentation.images.chatPlaceholderBackground];
        _backgroundImageView.frame = _containerView.bounds;
        [_containerView addSubview:_backgroundImageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = presentation.pallete.chatSystemTextColor;
        _titleLabel.font = TGMediumSystemFontOfSize(14.0f);
        
        NSString *titleText = [[NSString alloc] initWithFormat:incoming ? TGLocalized(@"Conversation.EncryptedPlaceholderTitleIncoming") : TGLocalized(@"Conversation.EncryptedPlaceholderTitleOutgoing"), userName];
        
        if ([_titleLabel respondsToSelector:@selector(setAttributedText:)])
        {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:titleText attributes:nil];
            
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 4;
            style.lineBreakMode = NSLineBreakByWordWrapping;
            style.alignment = NSTextAlignmentCenter;
            [attributedString addAttributes:@{NSParagraphStyleAttributeName: style} range:NSMakeRange(0, attributedString.length)];
            
            _titleLabel.attributedText = attributedString;
        }
        else
            _titleLabel.text = titleText;
        
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize labelSize = [_titleLabel sizeThatFits:CGSizeMake(200.0f, CGFLOAT_MAX)];
        _titleLabel.frame = CGRectMake(CGFloor((_containerView.frame.size.width - labelSize.width) / 2.0f), 17.0f, labelSize.width, labelSize.height);
        [_containerView addSubview:_titleLabel];
        
        _secondTitleLabel = [[UILabel alloc] init];
        _secondTitleLabel.backgroundColor = [UIColor clearColor];
        _secondTitleLabel.textColor = presentation.pallete.chatSystemTextColor;
        _secondTitleLabel.font = TGMediumSystemFontOfSize(14.0f);
        _secondTitleLabel.text = TGLocalized(@"Conversation.EncryptedDescriptionTitle");
        [_secondTitleLabel sizeToFit];
        _secondTitleLabel.frame = CGRectMake(TGIsRTL() ? minWidth - 16.0f - _secondTitleLabel.frame.size.width : 16.0f, CGRectGetMaxY(_titleLabel.frame) + 9.0f, _secondTitleLabel.frame.size.width, _secondTitleLabel.frame.size.height);
        [_containerView addSubview:_secondTitleLabel];
        
        UIImage *icon = TGTintedImage([TGPresentationAssets chatPlaceholderEncryptedIcon], presentation.pallete.chatSystemTextColor);
        
        _iconViews = [[NSMutableArray alloc] init];
        _labels = [[NSMutableArray alloc] init];
        
        NSArray *titles = @[
            TGLocalized(@"Conversation.EncryptedDescription1"),
            TGLocalized(@"Conversation.EncryptedDescription2"),
            TGLocalized(@"Conversation.EncryptedDescription3"),
            TGLocalized(@"Conversation.EncryptedDescription4")
        ];
        int index = -1;
        CGFloat currentLineY = CGRectGetMaxY(_secondTitleLabel.frame) + 5.0f;
        for (NSString *title in titles)
        {
            index++;
            currentLineY += [self addTextLine:title offset:currentLineY presentation:presentation icon:icon] + 5;
        }

        CGFloat height = currentLineY + 10.0f;
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
        _containerView.frame = self.bounds;
        _backgroundImageView.frame = _containerView.bounds;
        
        self.userInteractionEnabled = false;
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    if (_presentation != presentation)
    {
        _backgroundImageView.image = presentation.images.chatPlaceholderBackground;
        _titleLabel.textColor = presentation.pallete.chatSystemTextColor;
        _secondTitleLabel.textColor = presentation.pallete.chatSystemTextColor;
        
        UIImage *icon = TGTintedImage([TGPresentationAssets chatPlaceholderEncryptedIcon], presentation.pallete.chatSystemTextColor);
        for (UIImageView *iconView in _iconViews)
        {
            iconView.image = icon;
        }
        for (UILabel *label in _labels)
        {
            label.textColor = presentation.pallete.chatSystemTextColor;
        }
    }
}

- (CGFloat)addTextLine:(NSString *)text offset:(CGFloat)offset presentation:(TGPresentation *)presentation icon:(UIImage *)icon
{
    UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
    iconView.frame = CGRectOffset(iconView.frame, TGIsRTL() ? 236.0f - 16.0f - iconView.frame.size.width : 16.0f, offset + 2.0f);
    [_containerView addSubview:iconView];
    
    [_iconViews addObject:iconView];
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = presentation.pallete.chatSystemTextColor;
    label.font = TGSystemFontOfSize(14.0f);
    label.text = text;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize labelSize = [label sizeThatFits:CGSizeMake(200.0f, FLT_MAX)];
    label.frame = CGRectMake(TGIsRTL() ? 236.0f - 33.0f - labelSize.width : 33.0f, offset, labelSize.width, labelSize.height);
    [_containerView addSubview:label];
    
    [_labels addObject:label];
    
    return labelSize.height;
}

- (void)adjustLayoutForSize:(CGSize)size contentInsets:(UIEdgeInsets)contentInsets duration:(NSTimeInterval)duration curve:(int)curve
{
    [super adjustLayoutForSize:size contentInsets:contentInsets duration:duration curve:curve];
    
    CGSize messageAreaSize = size;
    
    CGRect frame = CGRectMake(CGFloor((messageAreaSize.width - self.frame.size.width) / 2.0f), contentInsets.top + CGFloor((messageAreaSize.height - self.frame.size.height - contentInsets.top - contentInsets.bottom) / 2.0f), self.frame.size.width, self.frame.size.height);;
    CGFloat alpha = messageAreaSize.height - contentInsets.top - contentInsets.bottom < (self.frame.size.height + 10) ? 0.0f : 1.0f;
    
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
