#import "TGChannelAdminLogEmptyView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGWallpaperManager.h"
#import <LegacyComponents/TGWallpaperInfo.h>

#import "TGPresentation.h"

@implementation TGChannelAdminLogEmptyFilter

- (instancetype)initWithQuery:(NSString *)query {
    self = [super init];
    if (self != nil) {
        _query = query;
    }
    return self;
}

@end

@interface TGChannelAdminLogEmptyView ()
{
    UIImageView *_backgroundImageView;
    UILabel *_titleLabel;
    UILabel *_secondTitleLabel;
    UIView *_containerView;
}

@end

@implementation TGChannelAdminLogEmptyView

@synthesize presentation = _presentation;

- (instancetype)initWithFilter:(TGChannelAdminLogEmptyFilter *)filter group:(bool)group presentation:(TGPresentation *)presentation
{
    static const CGFloat minWidth = 280.0f;
    
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, minWidth, 185.0f)];
    if (self != nil)
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
        _titleLabel.font = TGSemiboldSystemFontOfSize(17.0f);
        
        NSString *titleText = TGLocalized(@"Channel.AdminLog.EmptyTitle");
        if (filter != nil) {
            titleText = TGLocalized(@"Channel.AdminLog.EmptyFilterTitle");
        }
        NSString *bodyText = group ? TGLocalized(@"Channel.AdminLog.EmptyText") : TGLocalized(@"Channel.AdminLog.ChannelEmptyText");
        if (filter != nil) {
            if (filter.query.length != 0) {
                bodyText = [NSString stringWithFormat:TGLocalized(@"Channel.AdminLog.EmptyFilterQueryText"), filter.query];
            } else {
                bodyText = TGLocalized(@"Channel.AdminLog.EmptyFilterText");
            }
        }
        
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
        _secondTitleLabel.font = TGSystemFontOfSize(16.0f);
        _secondTitleLabel.textAlignment = NSTextAlignmentCenter;
        if ([_secondTitleLabel respondsToSelector:@selector(setAttributedText:)])
        {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:bodyText attributes:nil];
            
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 1;
            style.lineBreakMode = NSLineBreakByWordWrapping;
            style.alignment = NSTextAlignmentCenter;
            [attributedString addAttributes:@{NSParagraphStyleAttributeName: style} range:NSMakeRange(0, attributedString.length)];
            
            _secondTitleLabel.attributedText = attributedString;
        }
        else
            _secondTitleLabel.text = bodyText;
        _secondTitleLabel.numberOfLines = 0;
        CGSize secondTitleSize = [_secondTitleLabel sizeThatFits:CGSizeMake(220.0f, CGFLOAT_MAX)];
        _secondTitleLabel.frame = CGRectMake(CGFloor(minWidth - secondTitleSize.width) / 2.0, CGRectGetMaxY(_titleLabel.frame) + 9.0f, secondTitleSize.width, secondTitleSize.height);
        [_containerView addSubview:_secondTitleLabel];
        
        CGFloat currentLineY = CGRectGetMaxY(_secondTitleLabel.frame) + 5.0f;

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
        _secondTitleLabel.textColor = presentation.pallete.chatSystemTextColor;
    }
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
