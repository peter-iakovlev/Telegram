#import "TGPreviewTextItemView.h"
#import "TGBotContextResult.h"
#import "TGBotContextResultSendMessageText.h"

#import "TGFont.h"

#import "TGMessage.h"

const CGFloat TGPreviewTextItemViewMargin = 21.0f;

@interface TGPreviewTextItemView ()
{
    UILabel *_label;
}
@end

@implementation TGPreviewTextItemView

- (instancetype)initWithBotContextResult:(TGBotContextResult *)result
{
    self = [self init];
    if (self != nil)
    {
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor whiteColor];
        _label.font = TGSystemFontOfSize(17.0f);
        _label.textColor = [UIColor blackColor];
        [self addSubview:_label];
        
        if ([result.sendMessage isKindOfClass:[TGBotContextResultSendMessageText class]])
        {
            TGBotContextResultSendMessageText *sendMessage = (TGBotContextResultSendMessageText *)result.sendMessage;
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:sendMessage.message attributes:@{ NSFontAttributeName: _label.font, NSForegroundColorAttributeName: _label.textColor }];
            
            for (TGMessageEntity *entity in sendMessage.entities)
            {
                if ([entity isKindOfClass:[TGMessageEntityBold class]])
                {
                    [string addAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:_label.font.pointSize weight:UIFontWeightMedium] } range:entity.range];
                }
                else if ([entity isKindOfClass:[TGMessageEntityItalic class]])
                {
                    [string addAttributes:@{ NSFontAttributeName: [UIFont italicSystemFontOfSize:_label.font.pointSize] } range:entity.range];
                }
                else if ([entity isKindOfClass:[TGMessageEntityPre class]] || [entity isKindOfClass:[TGMessageEntityCode class]])
                {
                    [string addAttributes:@{ NSFontAttributeName: [UIFont fontWithName:@"Courier" size:_label.font.pointSize] } range:entity.range];
                }
                else if ([entity isKindOfClass:[TGMessageEntityUrl class]] || [entity isKindOfClass:[TGMessageEntityTextUrl class]] || [entity isKindOfClass:[TGMessageEntityEmail class]])
                {
                    [string addAttributes:@{ NSForegroundColorAttributeName: UIColorRGB(0x004bad) } range:entity.range];
                }
                else if ([entity isKindOfClass:[TGMessageEntityMention class]] || [entity isKindOfClass:[TGMessageEntityHashtag class]]
                         || [entity isKindOfClass:[TGMessageEntityMentionName class]] || [entity isKindOfClass:[TGMessageEntityBotCommand class]])
                {
                    [string addAttributes:@{ NSForegroundColorAttributeName: UIColorRGB(0x004bad) } range:entity.range];
                }
            }
            
            _label.attributedText = string;
        }
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width screenHeight:(CGFloat)__unused screenHeight
{
    [UIView performWithoutAnimation:^
    {
        _label.frame = CGRectMake(TGPreviewTextItemViewMargin, 15.0f, width - TGPreviewTextItemViewMargin * 2, 0);
        [_label sizeToFit];
    }];
    
    return ceil(CGRectGetMaxY(_label.frame) + 15.0f);
}

@end
