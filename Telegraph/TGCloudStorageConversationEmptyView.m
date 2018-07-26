#import "TGCloudStorageConversationEmptyView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGWallpaperManager.h"
#import <LegacyComponents/TGWallpaperInfo.h>

#import "TGPresentation.h"

@interface TGCloudStorageConversationEmptyView () {
    UIImageView *_backgroundImageView;
    UIImageView *_iconView;
    UILabel *_titleLabel;
    NSMutableArray *_labels;
    UIView *_containerView;
}

@end

@implementation TGCloudStorageConversationEmptyView

@synthesize presentation = _presentation;

- (instancetype)initWithFrame:(CGRect)__unused frame presentation:(TGPresentation *)presentation {
    static const CGFloat minWidth = 278.0f;
    
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, minWidth, 185.0f)];
    if (self != nil) {
        
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, minWidth, 185.0f)];
        [self addSubview:_containerView];
        
        _backgroundImageView = [[UIImageView alloc] initWithImage:presentation.images.chatPlaceholderBackground];
        _backgroundImageView.frame = _containerView.bounds;
        [_containerView addSubview:_backgroundImageView];
        
        UIImageView *iconView = [[UIImageView alloc] initWithImage:TGTintedImage(TGImageNamed(@"ChatCloudInfoIcon.png"), presentation.pallete.chatSystemTextColor)];
        iconView.frame = CGRectMake(CGFloor((minWidth - iconView.frame.size.width) / 2.0f), 26.0f, iconView.frame.size.width, iconView.frame.size.height);
        
        [_containerView addSubview:iconView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = presentation.pallete.chatSystemTextColor;
        _titleLabel.font = TGMediumSystemFontOfSize(14.0f);
        
        NSString *titleText = TGLocalized(@"Conversation.CloudStorageInfo.Title");
        
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
        _titleLabel.frame = CGRectMake(CGFloor((_containerView.frame.size.width - labelSize.width) / 2.0f), CGRectGetMaxY(iconView.frame) + 19.0f, labelSize.width, labelSize.height);
        [_containerView addSubview:_titleLabel];
        
        NSArray *titles = @[
                            TGLocalized(@"Conversation.ClousStorageInfo.Description1"),
                            TGLocalized(@"Conversation.ClousStorageInfo.Description2"),
                            TGLocalized(@"Conversation.ClousStorageInfo.Description3"),
                            TGLocalized(@"Conversation.ClousStorageInfo.Description4")
                            ];
        int index = -1;
        CGFloat currentLineY = CGRectGetMaxY(_titleLabel.frame) + 10.0f;
        for (NSString *title in titles)
        {
            index++;
            currentLineY += [self addTextLine:title offset:currentLineY presentation:presentation] + 5;
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
        _presentation = presentation;
        
        _backgroundImageView.image = presentation.images.chatPlaceholderBackground;
        _titleLabel.textColor = presentation.pallete.chatSystemTextColor;
        for (UILabel *label in _labels)
        {
            label.textColor = presentation.pallete.chatSystemTextColor;
        }
    }
}

- (CGFloat)addTextLine:(NSString *)text offset:(CGFloat)offset presentation:(TGPresentation *)presentation
{
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = presentation.pallete.chatSystemTextColor;
    label.font = TGSystemFontOfSize(14.0f);
    label.text = text;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize labelSize = [label sizeThatFits:CGSizeMake(260.0f, FLT_MAX)];
    label.frame = CGRectMake(TGIsRTL() ? (278.0f - 16.0f - labelSize.width) : 16.0f, offset, labelSize.width, labelSize.height);
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
