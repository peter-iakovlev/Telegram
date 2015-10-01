/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGSecretConversationEmptyListView.h"

#import "TGViewController.h"

#import "TGFont.h"
#import "TGStringUtils.h"

#import "TGWallpaperManager.h"
#import "TGWallpaperInfo.h"

@interface TGSecretConversationEmptyListView ()
{
    UIView *_containerView;
}

@end

@implementation TGSecretConversationEmptyListView

- (instancetype)initWithIncoming:(bool)incoming userName:(NSString *)userName
{
    static const CGFloat minWidth = 236.0f;
    
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
        titleLabel.font = TGMediumSystemFontOfSize(14.0f);
        
        NSString *titleText = [[NSString alloc] initWithFormat:incoming ? TGLocalized(@"Conversation.EncryptedPlaceholderTitleIncoming") : TGLocalized(@"Conversation.EncryptedPlaceholderTitleOutgoing"), userName];
        
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
        secondTitleLabel.font = TGMediumSystemFontOfSize(14.0f);
        secondTitleLabel.text = TGLocalized(@"Conversation.EncryptedDescriptionTitle");
        [secondTitleLabel sizeToFit];
        secondTitleLabel.frame = CGRectMake(TGIsRTL() ? minWidth - 16.0f - secondTitleLabel.frame.size.width : 16.0f, CGRectGetMaxY(titleLabel.frame) + 9.0f, secondTitleLabel.frame.size.width, secondTitleLabel.frame.size.height);
        [_containerView addSubview:secondTitleLabel];
        
        NSArray *titles = @[
            TGLocalized(@"Conversation.EncryptedDescription1"),
            TGLocalized(@"Conversation.EncryptedDescription2"),
            TGLocalized(@"Conversation.EncryptedDescription3"),
            TGLocalized(@"Conversation.EncryptedDescription4")
        ];
        int index = -1;
        CGFloat currentLineY = CGRectGetMaxY(secondTitleLabel.frame) + 5.0f;
        for (NSString *title in titles)
        {
            index++;
            currentLineY += [self addTextLine:title offset:currentLineY] + 5;
        }

        CGFloat height = currentLineY + 10.0f;
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
        _containerView.frame = self.bounds;
        backgroundImageView.frame = _containerView.bounds;
        
        self.userInteractionEnabled = false;
    }
    return self;
}

- (CGFloat)addTextLine:(NSString *)text offset:(CGFloat)offset
{
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernConversationEmptyListLockIcon.png"]];
    iconView.frame = CGRectOffset(iconView.frame, TGIsRTL() ? 236.0f - 16.0f - iconView.frame.size.width : 16.0f, offset + 2.0f);
    [_containerView addSubview:iconView];
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = TGSystemFontOfSize(14.0f);
    label.text = text;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize labelSize = [label sizeThatFits:CGSizeMake(200.0f, FLT_MAX)];
    label.frame = CGRectMake(TGIsRTL() ? 236.0f - 33.0f - labelSize.width : 33.0f, offset, labelSize.width, labelSize.height);
    [_containerView addSubview:label];
    
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
