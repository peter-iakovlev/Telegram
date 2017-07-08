#import "TGModernConversationWebPreviewInputPanel.h"

#import "TGModernButton.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGWebPageMediaAttachment.h"

@interface TGModernConversationWebPreviewInputPanel ()
{
    CGFloat _sendAreaWidth;
    CGFloat _attachmentAreaWidth;
    
    TGModernButton *_closeButton;
    UIView *_lineView;
    UILabel *_nameLabel;
    UILabel *_contentLabel;
}

@end

@implementation TGModernConversationWebPreviewInputPanel

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.backgroundColor = nil;
        self.opaque = false;
        
        UIImage *closeImage = [UIImage imageNamed:@"ReplyPanelClose.png"];
        _closeButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, closeImage.size.width, closeImage.size.height)];
        _closeButton.adjustsImageWhenHighlighted = false;
        [_closeButton setBackgroundImage:closeImage forState:UIControlStateNormal];
        
        _closeButton.extendedEdgeInsets = UIEdgeInsetsMake(16.0f, 16.0f, 16.0f, 16.0f);
        [_closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
        
        UIColor *color = UIColorRGB(0x34a5ff);
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = color;
        [self addSubview:_lineView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = nil;
        _nameLabel.opaque = false;
        _nameLabel.textColor = color;
        _nameLabel.font = TGSystemFontOfSize(14.5f);
        [self addSubview:_nameLabel];
        
        UIColor *mediaTextColor = UIColorRGB(0x8c8c92);
        
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = nil;
        _contentLabel.opaque = false;
        _contentLabel.textColor = mediaTextColor;
        _contentLabel.font = TGSystemFontOfSize(14.5f);
        [self addSubview:_contentLabel];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.alpha = frame.size.height >= FLT_EPSILON;
}

- (void)closeButtonPressed
{
    if (_dismiss)
        _dismiss();
}

- (CGFloat)preferredHeight
{
    return 41.0f;
}

- (void)setSendAreaWidth:(CGFloat)sendAreaWidth attachmentAreaWidth:(CGFloat)attachmentAreaWidth
{
    _sendAreaWidth = sendAreaWidth;
    _attachmentAreaWidth = attachmentAreaWidth;
}

- (NSString *)titleForWebpage:(TGWebPageMediaAttachment *)webPage
{
    if (webPage.siteName.length != 0)
        return webPage.siteName;
    
    return nil;
}

- (void)setLink:(NSString *)link webPage:(TGWebPageMediaAttachment *)webPage
{
    if ([self titleForWebpage:webPage].length == 0)
    {
        if (webPage.url.length != 0)
            _nameLabel.text = TGLocalized(@"WebPreview.LinkPreview");
        else
            _nameLabel.text = TGLocalized(@"WebPreview.GettingLinkInfo");
    }
    else
        _nameLabel.text = [self titleForWebpage:webPage];
    
    if (webPage.title.length != 0)
        _contentLabel.text = webPage.title;
    else if (webPage.pageDescription.length != 0)
        _contentLabel.text = webPage.pageDescription;
    else if ([webPage.pageType isEqualToString:@"photo"])
        _contentLabel.text = TGLocalized(@"Message.Photo");
    else if ([webPage.pageType isEqualToString:@"video"])
        _contentLabel.text = TGLocalized(@"Message.Video");
    else if (webPage.author.length != 0)
        _contentLabel.text = webPage.author;
    else
        _contentLabel.text = link;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [UIView performWithoutAnimation:^
    {
        CGSize boundsSize = CGSizeMake(self.bounds.size.width, [self preferredHeight]);
        
        CGFloat leftPadding = 0.0f;
        
        CGSize nameSize = [_nameLabel.text sizeWithFont:_nameLabel.font];
        nameSize.width = MIN(nameSize.width, boundsSize.width - _attachmentAreaWidth - 40.0f - _sendAreaWidth - leftPadding);
        
        CGSize contentLabelSize = [_contentLabel.text sizeWithFont:_contentLabel.font];
        contentLabelSize.width = MIN(contentLabelSize.width, boundsSize.width - _attachmentAreaWidth - 40.0f - _sendAreaWidth - leftPadding);
        
        _closeButton.frame = CGRectMake(boundsSize.width - _sendAreaWidth - _closeButton.frame.size.width - 7.0f, 11.0f, _closeButton.frame.size.width, _closeButton.frame.size.height);
        _lineView.frame = CGRectMake(_attachmentAreaWidth + 4.0f, 6.0f, 2.0f, boundsSize.height - 6.0f);
        _nameLabel.frame = CGRectMake(_attachmentAreaWidth + 16.0f + leftPadding, 5.0f, CGCeil(nameSize.width), CGCeil(nameSize.height));
        _contentLabel.frame = CGRectMake(_attachmentAreaWidth + 16.0f + leftPadding, 24.0f, CGCeil(contentLabelSize.width), CGCeil(contentLabelSize.height));
    }];
}

@end
