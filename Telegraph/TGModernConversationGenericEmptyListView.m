/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernConversationGenericEmptyListView.h"

#import "TGViewController.h"

#import "TGFont.h"

#import "TGWallpaperInfo.h"
#import "TGWallpaperManager.h"

@interface TGModernConversationGenericEmptyListView ()
{
    UIView *_containerView;
}

@end

@implementation TGModernConversationGenericEmptyListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 144.0f, 144.0f)];
    if (self)
    {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 144.0f, 144.0f)];
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
        
        UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernConversationEmptyListLogo.png"]];
        CGSize iconSize = iconView.frame.size;
        iconView.frame = CGRectMake(CGFloor((_containerView.frame.size.width - iconSize.width) / 2.0f), 14.0f, iconSize.width, iconSize.height);
        [_containerView addSubview:iconView];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = TGMediumSystemFontOfSize(14.0f);
        
        if ([titleLabel respondsToSelector:@selector(setAttributedText:)])
        {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:TGLocalized(@"Conversation.EmptyPlaceholder") attributes:nil];
            
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 2;
            style.lineBreakMode = NSLineBreakByWordWrapping;
            style.alignment = NSTextAlignmentCenter;
            [attributedString addAttributes:@{NSParagraphStyleAttributeName: style} range:NSMakeRange(0, attributedString.length)];
            
            titleLabel.attributedText = attributedString;
        }
        else
            titleLabel.text = TGLocalized(@"Conversation.EmptyPlaceholder");
        
        
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize labelSize = [titleLabel sizeThatFits:CGSizeMake(105.0f, CGFLOAT_MAX)];
        titleLabel.frame = CGRectMake(CGFloor((_containerView.frame.size.width - labelSize.width) / 2.0f), 114.0f - CGFloor(labelSize.height / 2.0f), labelSize.width, labelSize.height);
        [_containerView addSubview:titleLabel];
        
        self.userInteractionEnabled = false;
    }
    return self;
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
