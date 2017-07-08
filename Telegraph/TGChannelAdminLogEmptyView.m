#import "TGChannelAdminLogEmptyView.h"

#import "TGViewController.h"

#import "TGFont.h"
#import "TGStringUtils.h"

#import "TGWallpaperManager.h"
#import "TGWallpaperInfo.h"

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
    UIView *_containerView;
}

@end

@implementation TGChannelAdminLogEmptyView

- (instancetype)initWithFilter:(TGChannelAdminLogEmptyFilter *)filter
{
    static const CGFloat minWidth = 280.0f;
    
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, minWidth, 185.0f)];
    if (self)
    {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, minWidth, 185.0f)];
        [self addSubview:_containerView];
        
        static UIImage *backgroundImage = nil;
        static int backgroundColor = -1;
        
        if (backgroundColor == -1 || backgroundColor != [[TGWallpaperManager instance] currentWallpaperInfo].tintColor)
        {
            backgroundColor = [[TGWallpaperManager instance] currentWallpaperInfo].tintColor;
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(30.0f, 30.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGBA(backgroundColor, 0.35f).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 30.0f, 30.0f));
            backgroundImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:15 topCapHeight:15];
            UIGraphicsEndImageContext();
        }
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        backgroundImageView.frame = _containerView.bounds;
        [_containerView addSubview:backgroundImageView];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = TGSemiboldSystemFontOfSize(17.0f);
        
        NSString *titleText = TGLocalized(@"Channel.AdminLog.EmptyTitle");
        if (filter != nil) {
            titleText = TGLocalized(@"Channel.AdminLog.EmptyFilterTitle");
        }
        NSString *bodyText = TGLocalized(@"Channel.AdminLog.EmptyText");
        if (filter != nil) {
            if (filter.query.length != 0) {
                bodyText = [NSString stringWithFormat:TGLocalized(@"Channel.AdminLog.EmptyFilterQueryText"), filter.query];
            } else {
                bodyText = TGLocalized(@"Channel.AdminLog.EmptyFilterText");
            }
        }
        
        if ([titleLabel respondsToSelector:@selector(setAttributedText:)])
        {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:titleText attributes:nil];
            
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 4;
            style.lineBreakMode = NSLineBreakByWordWrapping;
            style.alignment = NSTextAlignmentCenter;
            [attributedString addAttributes:@{NSParagraphStyleAttributeName: style} range:NSMakeRange(0, attributedString.length)];
            
            titleLabel.attributedText = attributedString;
        }
        else
            titleLabel.text = titleText;
        
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize labelSize = [titleLabel sizeThatFits:CGSizeMake(200.0f, CGFLOAT_MAX)];
        titleLabel.frame = CGRectMake(CGFloor((_containerView.frame.size.width - labelSize.width) / 2.0f), 17.0f, labelSize.width, labelSize.height);
        [_containerView addSubview:titleLabel];
        
        UILabel *secondTitleLabel = [[UILabel alloc] init];
        secondTitleLabel.backgroundColor = [UIColor clearColor];
        secondTitleLabel.textColor = [UIColor whiteColor];
        secondTitleLabel.font = TGSystemFontOfSize(16.0f);
        secondTitleLabel.textAlignment = NSTextAlignmentCenter;
        if ([secondTitleLabel respondsToSelector:@selector(setAttributedText:)])
        {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:bodyText attributes:nil];
            
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 1;
            style.lineBreakMode = NSLineBreakByWordWrapping;
            style.alignment = NSTextAlignmentCenter;
            [attributedString addAttributes:@{NSParagraphStyleAttributeName: style} range:NSMakeRange(0, attributedString.length)];
            
            secondTitleLabel.attributedText = attributedString;
        }
        else
            secondTitleLabel.text = bodyText;
        secondTitleLabel.numberOfLines = 0;
        CGSize secondTitleSize = [secondTitleLabel sizeThatFits:CGSizeMake(220.0f, CGFLOAT_MAX)];
        secondTitleLabel.frame = CGRectMake(CGFloor(minWidth - secondTitleSize.width) / 2.0, CGRectGetMaxY(titleLabel.frame) + 9.0f, secondTitleSize.width, secondTitleSize.height);
        [_containerView addSubview:secondTitleLabel];
        
        CGFloat currentLineY = CGRectGetMaxY(secondTitleLabel.frame) + 5.0f;

        CGFloat height = currentLineY + 10.0f;
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
        _containerView.frame = self.bounds;
        backgroundImageView.frame = _containerView.bounds;
        
        self.userInteractionEnabled = false;
    }
    return self;
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
