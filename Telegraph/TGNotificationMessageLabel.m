/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGNotificationMessageLabel.h"

@implementation TGNotificationMessageLabel

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect rect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    rect.origin.y = 0.0f;
    return rect;
}

- (void)drawTextInRect:(CGRect)__unused rect
{
    if (iosMajorVersion() < 7)
    {
        [super drawTextInRect:[self textRectForBounds:self.bounds limitedToNumberOfLines:2]];
    }
    else
    {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 1;
        style.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attributes = @{
            NSParagraphStyleAttributeName: style,
            NSFontAttributeName: self.font,
            NSForegroundColorAttributeName: self.textColor
        };

        [self.text drawWithRect:self.bounds options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil];
    }
}

@end
