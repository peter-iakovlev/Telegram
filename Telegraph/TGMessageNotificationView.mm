/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMessageNotificationView.h"

#import "TGInterfaceAssets.h"

#import "TGPeerIdAdapter.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGNotificationWindow.h"

#import "TGLetteredAvatarView.h"

#import "TGFont.h"

#import "TGNotificationMessageLabel.h"

@interface TGMessageNotificationView ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) CALayer *shadowLayer;

@property (nonatomic, strong) TGLetteredAvatarView *avatarView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) TGNotificationMessageLabel *messageLabel;
@property (nonatomic, strong) UIButton *dismissButton;

@property (nonatomic, strong) NSMutableAttributedString *attributedText;

@end

@implementation TGMessageNotificationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20 + 44)];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _backgroundView.backgroundColor = UIColorRGBA(0x000000, 0.8f);
        [self addSubview:_backgroundView];
        
        _shadowLayer = [[CALayer alloc] init];
        _shadowLayer.backgroundColor = UIColorRGBA(0x000000, 0.5f).CGColor;
        _shadowLayer.frame = CGRectMake(0, 20 + 44 - 1, self.bounds.size.width, 1);
        [self.layer addSublayer:_shadowLayer];
        
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(10, 10, 44, 44)];
        [_avatarView setSingleFontSize:17.0f doubleFontSize:17.0f useBoldFont:true];
        [self addSubview:_avatarView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 3, self.bounds.size.width - 8 - 32 - 70, 18)];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = TGMediumSystemFontOfSize(14);
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        if (TGIsRTL())
            _titleLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_titleLabel];
        
        _messageLabel = [[TGNotificationMessageLabel alloc] initWithFrame:CGRectMake(64, 23, self.bounds.size.width - 8 - 32 - 70, 36)];
        _messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.font = TGSystemFontOfSize(14);
        _messageLabel.numberOfLines = 2;
        _messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_messageLabel];
        
        UIImage *buttonImage = [UIImage imageNamed:@"BannerClose.png"];
        _dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - buttonImage.size.width, 0, buttonImage.size.width, buttonImage.size.height)];
        _dismissButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _dismissButton.exclusiveTouch = true;
        [_dismissButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self addSubview:_dismissButton];
        
        [_dismissButton addTarget:self action:@selector(dismissButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _titleLabel.userInteractionEnabled = false;
        _messageLabel.userInteractionEnabled = false;
        _avatarView.userInteractionEnabled = false;
        
        _backgroundView.userInteractionEnabled = true;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
        [_backgroundView addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (void)resetView
{
    bool attachmentFound = false;
    
    NSString *messageText = _messageText;
    
    if (_messageAttachments != nil && _messageAttachments.count != 0)
    {
        for (TGMediaAttachment *attachment in _messageAttachments)
        {
            if (attachment.type == TGActionMediaAttachmentType)
            {
                TGActionMediaAttachment *actionAttachment = (TGActionMediaAttachment *)attachment;
                switch (actionAttachment.actionType)
                {
                    case TGMessageActionChatEditTitle:
                    {
                        TGUser *user = [_users objectForKey:@"author"];
                        messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.RenamedChat"), user.displayName];
                        attachmentFound = true;
                        
                        break;
                    }
                    case TGMessageActionChatEditPhoto:
                    {
                        TGUser *user = [_users objectForKey:@"author"];
                        if ([(TGImageMediaAttachment *)[actionAttachment.actionData objectForKey:@"photo"] imageInfo] == nil)
                            messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.RemovedGroupPhoto"), user.displayName];
                        else
                            messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.ChangedGroupPhoto"), user.displayName];
                        attachmentFound = true;
                        
                        break;
                    }
                    case TGMessageActionUserChangedPhoto:
                    {
                        TGUser *user = [_users objectForKey:@"author"];
                        if ([(TGImageMediaAttachment *)[actionAttachment.actionData objectForKey:@"photo"] imageInfo] == nil)
                            messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.RemovedUserPhoto"), user.displayName];
                        else
                            messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.ChangedUserPhoto"), user.displayName];
                        attachmentFound = true;
                        
                        break;
                    }
                    case TGMessageActionChatAddMember:
                    {
                        NSNumber *nUid = [actionAttachment.actionData objectForKey:@"uid"];
                        if (nUid != nil)
                        {
                            TGUser *authorUser = [_users objectForKey:@"author"];
                            TGUser *subjectUser = [_users objectForKey:nUid];
                            if (authorUser.uid == subjectUser.uid)
                                messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.JoinedChat"), authorUser.displayName];
                            else
                                messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.Invited"), authorUser.displayName, subjectUser.displayName];
                            attachmentFound = true;
                        }
                        
                        break;
                    }
                    case TGMessageActionChatDeleteMember:
                    {
                        NSNumber *nUid = [actionAttachment.actionData objectForKey:@"uid"];
                        if (nUid != nil)
                        {
                            TGUser *authorUser = [_users objectForKey:@"author"];
                            TGUser *subjectUser = [_users objectForKey:nUid];
                            if (authorUser.uid == subjectUser.uid)
                                messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.LeftChat"), authorUser.displayName];
                            else
                                messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.Kicked"), authorUser.displayName, subjectUser.displayName];
                            attachmentFound = true;
                        }
                        
                        break;
                    }
                    case TGMessageActionCreateChat:
                    {
                        TGUser *user = [_users objectForKey:@"author"];
                        messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.CreatedChat"), user.displayName];
                        attachmentFound = true;
                        
                        break;
                    }
                    case TGMessageActionChannelCreated:
                    {
                        messageText = TGLocalized(@"Notification.CreatedChannel");
                        attachmentFound = true;
                        
                        break;
                    }
                    case TGMessageActionChannelCommentsStatusChanged:
                    {
                        messageText = [actionAttachment.actionData[@"enabled"] boolValue] ? TGLocalized(@"Channel.NotificationCommentsEnabled") : TGLocalized(@"Channel.NotificationCommentsDisabled");;
                        attachmentFound = true;
                        
                        break;
                    }
                    case TGMessageActionContactRegistered:
                    {
                        TGUser *user = [_users objectForKey:@"author"];
                        messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.Joined"), user.displayName];
                        attachmentFound = true;
                        
                        break;
                    }
                    case TGMessageActionEncryptedChatRequest:
                    {
                        messageText = TGLocalized(@"Notification.EncryptedChatRequested");
                        attachmentFound = true;
                        
                        break;
                    }
                    case TGMessageActionEncryptedChatAccept:
                    {
                        messageText = TGLocalized(@"Notification.EncryptedChatAccepted");
                        attachmentFound = true;
                        
                        break;
                    }
                    case TGMessageActionEncryptedChatDecline:
                    {
                        messageText = TGLocalized(@"Notification.EncryptedChatRejected");
                        attachmentFound = true;
                        
                        break;
                    }
                    default:
                        break;
                }
            }
            else if (attachment.type == TGImageMediaAttachmentType)
            {
                messageText = TGLocalized(@"Message.Photo");
                attachmentFound = true;
                break;
            }
            else if (attachment.type == TGVideoMediaAttachmentType)
            {
                messageText = TGLocalized(@"Message.Video");
                attachmentFound = true;
                break;
            }
            else if (attachment.type == TGLocationMediaAttachmentType)
            {
                messageText = TGLocalized(@"Message.Location");
                attachmentFound = true;
                break;
            }
            else if (attachment.type == TGContactMediaAttachmentType)
            {
                messageText = TGLocalized(@"Message.Contact");
                attachmentFound = true;
                break;
            }
            else if (attachment.type == TGDocumentMediaAttachmentType)
            {
                TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                
                bool isAnimated = false;
                CGSize imageSize = CGSizeZero;
                bool isSticker = false;
                for (id attribute in documentAttachment.attributes)
                {
                    if ([attribute isKindOfClass:[TGDocumentAttributeAnimated class]])
                    {
                        isAnimated = true;
                    }
                    else if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]])
                    {
                        imageSize = ((TGDocumentAttributeImageSize *)attribute).size;
                    }
                    else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                    {
                        isSticker = true;
                    }
                }
                
                if (isSticker)
                    messageText = TGLocalized(@"Message.Sticker");
                else
                    messageText = TGLocalized(@"Message.File");
                
                attachmentFound = true;
                break;
            }
            else if (attachment.type == TGAudioMediaAttachmentType)
            {
                messageText = TGLocalized(@"Message.Audio");
                attachmentFound = true;
                break;
            }
        }
    }
    
    /*if (attachmentFound)
        _messageLabel.textColor = UIColorRGB(0x0779d0);
    else
        _messageLabel.textColor = [UIColor blackColor];*/
    
    _messageLabel.text = messageText;
    
    float retinaPixel = TGIsRetina() ? 0.5f : 0.0f;
    
    if (_isLocationNotification)
    {
    }
    else
    {
        if ([_titleText isKindOfClass:[NSAttributedString class]])
            _titleLabel.attributedText = (NSAttributedString *)_titleText;
        else
            _titleLabel.text = _titleText;
        
        //_titleLabel.textColor = [[TGInterfaceAssets instance] userColor:_authorUid];
        
        _titleLabel.frame = CGRectMake(64, 4 + retinaPixel, self.bounds.size.width - 8 - 32 - 70, 18);
        
        static UIImage *placeholder = nil;
        static dispatch_once_t onceToken2;
        dispatch_once(&onceToken2, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(36.0f, 36.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            //!placeholder
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 36.0f, 36.0f));
            CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
            CGContextSetLineWidth(context, 1.0f);
            CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, 35.0f, 35.0f));
            
            placeholder = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        if (_avatarUrl != nil)
            [_avatarView loadImage:_avatarUrl filter:@"circle:44x44" placeholder:placeholder];
        else if (_authorUid < 0 && TGPeerIdIsChannel(_conversationId)) {
            [_avatarView loadGroupPlaceholderWithSize:CGSizeMake(44.0f, 44.0f) conversationId:_conversationId title:_firstName placeholder:placeholder];
        } else {
            [_avatarView loadUserPlaceholderWithSize:CGSizeMake(44.0f, 44.0f) uid:_authorUid firstName:_firstName lastName:_lastName placeholder:placeholder];
        }
    }
}

- (void)searchParentAndDismiss:(UIView *)view
{
    if (view == nil)
        return;
    
    if ([view isKindOfClass:[TGNotificationWindow class]])
    {
        [((TGNotificationWindow *)view) animateOut];
    }
    else
        [self searchParentAndDismiss:view.superview];
}

- (void)searchParentAndTap:(UIView *)view
{
    if (view == nil)
        return;
    
    if ([view isKindOfClass:[TGNotificationWindow class]])
    {
        [((TGNotificationWindow *)view) performTapAction];
    }
    else
        [self searchParentAndTap:view.superview];
}

- (void)dismissButtonPressed
{
    [self searchParentAndDismiss:self.superview];
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [self searchParentAndTap:self.superview];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _shadowLayer.frame = CGRectMake(0, 20 + 44 - 1, self.bounds.size.width, 1);
}

@end
