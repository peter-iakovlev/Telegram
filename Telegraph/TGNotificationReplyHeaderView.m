#import "TGNotificationReplyHeaderView.h"

#import "TGFont.h"
#import "TGImageView.h"

#import "TGReplyMessageMediaAttachment.h"
#import "TGConversation.h"
#import "TGMessage.h"
#import "TGUser.h"

#import "TGReplyHeaderActionModel.h"

const CGFloat TGNotificationReplyHeaderHeight = 29.0f;

@interface TGNotificationReplyHeaderView ()
{
    UIImageView *_lineView;
    TGImageView *_imageView;
    UILabel *_nameLabel;
    UILabel *_textLabel;
}
@end

@implementation TGNotificationReplyHeaderView

- (instancetype)initWithAttachment:(TGReplyMessageMediaAttachment *)attachment peers:(NSDictionary *)peers
{
    self = [super initWithFrame:CGRectZero];
    if (self != nil)
    {
        static UIImage *lineImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(3.0f, 3.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextSetFillColorWithColor(context, UIColorRGB(0x9c9c9c).CGColor);
            [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 3.0f, 3.0f) cornerRadius:1.5f] fill];

            lineImage = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(1.5f, 1.5f, 1.5f, 1.5f)];
            UIGraphicsEndImageContext();
        });
        
        _lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 3, TGNotificationReplyHeaderHeight)];
        _lineView.image = lineImage;
        [self addSubview:_lineView];
        
        _imageView = [[TGImageView alloc] initWithFrame:CGRectMake(11, 0.5f, 28, 28)];
        [self addSubview:_imageView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = TGMediumSystemFontOfSize(14.0f);
        _nameLabel.textColor = [UIColor whiteColor];
        [self addSubview:_nameLabel];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.font = TGMediumSystemFontOfSize(13.0f);
        _textLabel.textColor = [UIColor whiteColor];
        [self addSubview:_textLabel];
        
        id author = peers[@(attachment.replyMessage.fromUid)];
        if ([author isKindOfClass:[TGUser class]])
            _nameLabel.text = ((TGUser *)author).displayName;
        else if ([author isKindOfClass:[TGConversation class]])
            _nameLabel.text = ((TGConversation *)author).chatTitle;
        
        NSString *messageText = nil;
        for (TGMediaAttachment *subAttachment in attachment.replyMessage.mediaAttachments)
        {
            switch (subAttachment.type)
            {
                case TGImageMediaAttachmentType:
                {
                    TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)subAttachment;
                    NSString *text = imageAttachment.caption;
                    if (text.length == 0)
                        text = TGLocalized(@"Message.Photo");
                    
                    messageText = text;
                }
                    break;
                    
                case TGVideoMediaAttachmentType:
                {
                    TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)subAttachment;
                    NSString *text = videoAttachment.caption;
                    if (videoAttachment.roundMessage)
                        text = TGLocalized(@"Message.VideoMessage");
                    else if (text.length == 0)
                        text = TGLocalized(@"Message.Video");
                    
                    messageText = text;
                }
                    break;
                    
                case TGAudioMediaAttachmentType:
                {
                    messageText = TGLocalized(@"Message.Audio");
                }
                    break;
                    
                case TGDocumentMediaAttachmentType:
                {
                    TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)subAttachment;
                    bool isSticker = false;
                    bool isVoice = false;
                    NSString *stickerRepresentation = @"";
                    
                    for (id attribute in documentAttachment.attributes)
                    {
                        if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                        {
                            TGDocumentAttributeSticker *stickerAttribute = (TGDocumentAttributeSticker *)attribute;
                            stickerRepresentation = stickerAttribute.alt;
                            isSticker = true;
                            break;
                        }
                        else if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                            isVoice = ((TGDocumentAttributeAudio *)attribute).isVoice;
                        }
                    }
                    
                    if (isSticker)
                    {
                        if (stickerRepresentation.length > 0)
                            messageText = [NSString stringWithFormat:@"%@%@", stickerRepresentation, TGLocalized(@"Message.Sticker")];
                        else
                            messageText = TGLocalized(@"Message.Sticker");
                    }
                    else if ([documentAttachment isAnimated]) {
                        messageText = TGLocalized(@"Message.Animation");
                    }
                    else if (isVoice) {
                        messageText = TGLocalized(@"Message.Audio");
                    }
                    else
                    {
                        messageText = documentAttachment.fileName;
                    }

                }
                    break;
                    
                case TGContactMediaAttachmentType:
                {
                    messageText = TGLocalized(@"Message.Contact");
                }
                    break;
                    
                case TGLocationMediaAttachmentType:
                {
                    messageText = TGLocalized(@"Message.Location");
                }
                    break;
                    
                case TGActionMediaAttachmentType:
                {
                    messageText = [TGReplyHeaderActionModel messageTextForActionMedia:(TGActionMediaAttachment *)subAttachment otherAttachments:attachment.replyMessage.mediaAttachments author:author];
                }
                    break;
                    
                default:
                    break;
            }
        }
        
        if (messageText == nil)
            messageText = attachment.replyMessage.text;
            
        _textLabel.text = messageText;
        
        CGFloat textX = 9.0f;
        [_nameLabel sizeToFit];
        _nameLabel.frame = CGRectMake(textX, -2, ceil(_nameLabel.frame.size.width), ceil(_nameLabel.frame.size.height));
        
        [_textLabel sizeToFit];
        _textLabel.frame = CGRectMake(textX, 15, ceil(_textLabel.frame.size.width), ceil(_textLabel.frame.size.height));
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat textX = 9.0f;
    _nameLabel.frame = CGRectMake(textX, -2, self.frame.size.width - textX, _nameLabel.frame.size.height);
    _textLabel.frame = CGRectMake(textX, 15, self.frame.size.width - textX, _textLabel.frame.size.height);
}

@end
