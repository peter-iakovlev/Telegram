#import "TGAttachmentSheetFileInstructionSchemeView.h"

#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"

@interface TGAttachmentSheetFileInstructionSchemeView ()
{
    UIImageView *_imageView;
    UILabel *_openInLabel;
}
@end

@implementation TGAttachmentSheetFileInstructionSchemeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 133)];
        _imageView.image = [UIImage imageNamed:@"FileHowToScheme.png"];
        [self addSubview:_imageView];
        
        _openInLabel = [[UILabel alloc] init];
        _openInLabel.textAlignment = NSTextAlignmentLeft;
        _openInLabel.backgroundColor = UIColorRGB(0xf4f4f4);
        _openInLabel.font = TGSystemFontOfSize(9);
        _openInLabel.text = TGLocalized(@"Conversation.FileOpenIn");
        _openInLabel.textColor = TGAccentColor();
        [_openInLabel sizeToFit];
        [_imageView addSubview:_openInLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    _openInLabel.frame = CGRectMake(TGIsRTL() ? 113 + 94 - _openInLabel.frame.size.width : 113, 49, _openInLabel.frame.size.width, _openInLabel.frame.size.height);
}

@end
