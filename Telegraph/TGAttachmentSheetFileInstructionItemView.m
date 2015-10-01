#import "TGAttachmentSheetFileInstructionItemView.h"

#import "TGModernButton.h"
#import "TGStringUtils.h"
#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGAttachmentSheetFileInstructionSchemeView.h"

const CGFloat TGAttachmentSheetFileInstructionItemViewPadding = 15.0f;

@interface TGAttachmentSheetFileInstructionItemView ()
{
    TGModernButton *_titleButton;
    TGAttachmentSheetFileInstructionSchemeView *_instructionImageView;
    UILabel *_textLabel;
}
@end

@implementation TGAttachmentSheetFileInstructionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.clipsToBounds = true;
        
        _titleButton = [[TGModernButton alloc] init];
        _titleButton.exclusiveTouch = true;
        [_titleButton setTitle:TGLocalized(@"Conversation.FileHowTo") forState:UIControlStateNormal];
        [_titleButton setTitleColor:TGAccentColor()];
        _titleButton.titleLabel.font = TGSystemFontOfSize(20.0f + TGRetinaPixel);
        CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
        _titleButton.backgroundSelectionInsets = UIEdgeInsetsMake(1.0f + separatorHeight, 0.0f, 1.0f, 0.0f);
        _titleButton.highlightBackgroundColor = TGSelectionColor();
        [_titleButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_titleButton];
        
        __weak TGAttachmentSheetFileInstructionItemView *weakSelf = self;
        _titleButton.highlitedChanged = ^(bool highlighted)
        {
            __strong TGAttachmentSheetFileInstructionItemView *strongSelf = weakSelf;
            if (strongSelf != nil && highlighted)
            {
                for (UIView *sibling in strongSelf.superview.subviews.reverseObjectEnumerator)
                {
                    if ([sibling isKindOfClass:[TGAttachmentSheetItemView class]])
                    {
                        if (sibling != strongSelf)
                        {
                            [strongSelf.superview exchangeSubviewAtIndex:[strongSelf.superview.subviews indexOfObject:strongSelf] withSubviewAtIndex:[strongSelf.superview.subviews indexOfObject:sibling]];
                        }
                        break;
                    }
                }
            }
        };
    
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = UIColorRGB(0x808080);
        _textLabel.font = TGSystemFontOfSize(15.0f + TGRetinaPixel);
        
        NSString *instructionText = [[NSString alloc] initWithFormat:TGLocalized(@"Conversation.FileHowToText"), [TGStringUtils stringForDeviceType]];
        _textLabel.attributedText = [instructionText attributedStringWithFormattingAndFontSize:15.0f + TGRetinaPixel lineSpacing:3.0f paragraphSpacing:-1.0f];
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_textLabel];
        
        _instructionImageView = [[TGAttachmentSheetFileInstructionSchemeView alloc] initWithFrame:CGRectMake(0, 0, 320, 133)];
        [self addSubview:_instructionImageView];
    }
    return self;
}

- (void)buttonPressed
{
    if (self.pressed != nil)
        self.pressed();
}

- (void)setFolded:(bool)folded
{
    _folded = folded;
    
    _titleButton.userInteractionEnabled = folded;
    [_titleButton setTitleColor:folded ? TGAccentColor() : [UIColor blackColor]];
    
    _instructionImageView.alpha = folded ? 0.0f : 1.0f;
    _textLabel.alpha = folded ? 0.0f : 1.0f;
}

- (CGFloat)preferredHeight
{
    if (self.folded)
        return 50.0f;
    
    CGFloat height = 0.0f;
    CGSize screenSize = TGScreenSize();
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
    {
        CGSize textSize = [_textLabel sizeThatFits:CGSizeMake(screenSize.width - TGAttachmentSheetFileInstructionItemViewPadding * 2.0f, CGFLOAT_MAX)];
        height = 196.0f + textSize.height + 15.0f;
    }
    else
    {
        CGSize textSize = [_textLabel sizeThatFits:CGSizeMake(screenSize.height - TGAttachmentSheetFileInstructionItemViewPadding * 2.0f, CGFLOAT_MAX)];
        height = 50.0f + textSize.height + 15.0f;
    }
    
    return height;
}

- (bool)wantsFullSeparator
{
    return !self.folded;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _titleButton.frame = CGRectMake(0.0f, 1.0f, self.bounds.size.width, self.folded ? 48.0f : 50.0f);

    CGSize screenSize = TGScreenSize();
    
    if (ABS(self.frame.size.width - screenSize.width) < FLT_EPSILON)
    {
        _instructionImageView.frame = CGRectMake((self.frame.size.width - _instructionImageView.frame.size.width) / 2, CGRectGetMaxY(_titleButton.frame), _instructionImageView.frame.size.width, _instructionImageView.frame.size.height);
        
        CGSize textSize = [_textLabel sizeThatFits:CGSizeMake(self.bounds.size.width - TGAttachmentSheetFileInstructionItemViewPadding * 2.0f, CGFLOAT_MAX)];
        _textLabel.frame = CGRectMake(TGAttachmentSheetFileInstructionItemViewPadding, CGRectGetMaxY(_instructionImageView.frame) + 12.0f, CGCeil(textSize.width), CGCeil(textSize.height));
    }
    else
    {
        _instructionImageView.frame = CGRectMake(self.bounds.size.width, CGRectGetMaxY(_titleButton.frame), _instructionImageView.frame.size.width, _instructionImageView.frame.size.height);
        
        CGSize textSize = [_textLabel sizeThatFits:CGSizeMake(self.bounds.size.width - TGAttachmentSheetFileInstructionItemViewPadding * 2.0f, CGFLOAT_MAX)];
        _textLabel.frame = CGRectMake(TGAttachmentSheetFileInstructionItemViewPadding, CGRectGetMaxY(_titleButton.frame), CGCeil(textSize.width), CGCeil(textSize.height));
    }
}

@end
