#import "TGNotificationContentView.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGLetteredAvatarView.h>

#import "TGNotificationTextPreviewView.h"
#import "TGNotificationMediaPreviewView.h"
#import "TGNotificationStickerPreviewView.h"
#import "TGNotificationAudioPreviewView.h"
#import "TGNotificationFilePreviewView.h"
#import "TGNotificationContactPreviewView.h"
#import "TGNotificationVenuePreviewView.h"

@interface TGNotificationContentView ()
{
    TGLetteredAvatarView *_avatarView;
}
@end

@implementation TGNotificationContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(9, 10, 43.0f, 43.0f)];
        [_avatarView setSingleFontSize:17.0f doubleFontSize:17.0f useBoldFont:true];
        _avatarView.userInteractionEnabled = false;
        [self addSubview:_avatarView];
    }
    return self;
}

- (void)configureWithMessage:(TGMessage *)message conversation:(TGConversation *)conversation peers:(NSDictionary *)peers
{
    [self updatePreviewWithMessage:message conversation:conversation peers:peers];
    [self updateAvatarWithMessage:message conversation:conversation peers:peers];
    
    [self setNeedsLayout];
}

- (void)updatePreviewWithMessage:(TGMessage *)message conversation:(TGConversation *)conversation peers:(NSDictionary *)peers
{
    bool isSecretMessage = (conversation.encryptedData != nil);
    
    if (!isSecretMessage && message.mediaAttachments.count > 0)
    {
        for (TGMediaAttachment *attachment in message.mediaAttachments)
        {
            if (attachment.type == TGImageMediaAttachmentType)
            {
                _previewView = [[TGNotificationMediaPreviewView alloc] initWithMessage:message conversation:conversation attachment:attachment peers:peers];
                if (self.isMediaAvailable != nil)
                    [_previewView updateMediaAvailability:self.isMediaAvailable(attachment)];
                break;
            }
            else if (attachment.type == TGVideoMediaAttachmentType)
            {
                _previewView = [[TGNotificationMediaPreviewView alloc] initWithMessage:message conversation:conversation attachment:attachment peers:peers];
                break;
            }
            else if (attachment.type == TGLocationMediaAttachmentType)
            {
                TGLocationMediaAttachment *locationAttachment = (TGLocationMediaAttachment *)attachment;
                if (locationAttachment.venue != nil)
                {
                    _previewView = [[TGNotificationVenuePreviewView alloc] initWithMessage:message conversation:conversation attachment:locationAttachment peers:peers];
                }
                else
                {
                    _previewView = [[TGNotificationMediaPreviewView alloc] initWithMessage:message conversation:conversation attachment:locationAttachment peers:peers];
                }
                break;
            }
            else if (attachment.type == TGContactMediaAttachmentType)
            {
                _previewView = [[TGNotificationContactPreviewView alloc] initWithMessage:message conversation:conversation attachment:(TGContactMediaAttachment *)attachment peers:peers];
                break;
            }
            else if (attachment.type == TGDocumentMediaAttachmentType)
            {
                TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                
                bool isSticker = false;
                bool isVoice = false;
                for (id attribute in documentAttachment.attributes)
                {
                    if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                        isSticker = true;
                    if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                        isVoice = ((TGDocumentAttributeAudio *)attribute).isVoice;
                    }
                }
                
                if (isSticker)
                {
                    _previewView = [[TGNotificationStickerPreviewView alloc] initWithMessage:message conversation:conversation attachment:(TGDocumentMediaAttachment *)attachment peers:peers];
                }
                else if ([documentAttachment isAnimated]) {
                    _previewView = [[TGNotificationTextPreviewView alloc] initWithMessage:message conversation:conversation peers:peers];
                }
                else if (isVoice) {
                    _previewView = [[TGNotificationAudioPreviewView alloc] initWithMessage:message conversation:conversation attachment:(TGDocumentMediaAttachment *)attachment peers:peers];
                    if (self.isMediaAvailable != nil)
                        [_previewView updateMediaAvailability:self.isMediaAvailable(attachment)];
                }
                else
                {
                    _previewView = [[TGNotificationFilePreviewView alloc] initWithMessage:message conversation:conversation attachment:(TGDocumentMediaAttachment *)attachment peers:peers];
                }
                break;
            }
            else if (attachment.type == TGAudioMediaAttachmentType)
            {
                _previewView = [[TGNotificationAudioPreviewView alloc] initWithMessage:message conversation:conversation attachment:(TGAudioMediaAttachment *)attachment peers:peers];
                if (self.isMediaAvailable != nil)
                    [_previewView updateMediaAvailability:self.isMediaAvailable(attachment)];
                break;
            }
        }
    }

    if (_previewView == nil)
        _previewView = [[TGNotificationTextPreviewView alloc] initWithMessage:message conversation:conversation peers:peers];
    
    _previewView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _previewView.frame = self.bounds;
    _previewView.requestMedia = self.requestMedia;
    _previewView.cancelMedia = self.cancelMedia;
    _previewView.playMedia = self.playMedia;
    _previewView.mediaContext = self.mediaContext;
    
    [self addSubview:_previewView];
}

- (void)updateAvatarWithMessage:(TGMessage *)message conversation:(TGConversation *)conversation peers:(NSDictionary *)peers
{
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(43.0f, 43.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 43.0f, 43.0f));
        CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, 42.0f, 42.0f));
        
        placeholder = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    TGUser *user = peers[@"author"];

    if (user.photoUrlSmall != nil)
    {
        [_avatarView loadImage:user.photoUrlSmall filter:@"circle:44x44" placeholder:placeholder];
    }
    else if (TGPeerIdIsChannel(message.cid))
    {
        if (conversation.chatPhotoSmall != nil)
            [_avatarView loadImage:conversation.chatPhotoSmall filter:@"circle:44x44" placeholder:placeholder];
        else
            [_avatarView loadGroupPlaceholderWithSize:CGSizeMake(44.0f, 44.0f) conversationId:message.cid title:conversation.chatTitle placeholder:placeholder];
    }
    else
    {
        [_avatarView loadUserPlaceholderWithSize:CGSizeMake(44.0f, 44.0f) uid:(int32_t)message.fromUid firstName:user.firstName lastName:user.lastName placeholder:placeholder];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if ([_previewView isKindOfClass:[TGNotificationTextPreviewView class]] || [_previewView isKindOfClass:[TGNotificationAudioPreviewView class]])
        return view;
    
    return nil;
}

- (void)reset
{
    [_previewView removeFromSuperview];
    _previewView = nil;
}

- (void)layoutSubviews
{
    _previewView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

@end
