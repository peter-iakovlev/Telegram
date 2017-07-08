#import "TGModernConversationEditingMessageInputPanel.h"

#import "TGPeerIdAdapter.h"

#import "TGModernButton.h"

#import "TGDatabase.h"
#import "TGInterfaceAssets.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGImageView.h"

#import "TGSharedMediaSignals.h"
#import "TGSharedPhotoSignals.h"
#import "TGSharedVideoSignals.h"
#import "TGSharedMediaUtils.h"

#import "TGReplyHeaderModel.h"
#import "TGReplyHeaderActionModel.h"

#import "TGTelegramNetworking.h"

#import "TGTelegraph.h"

@interface TGModernConversationEditingMessageInputPanel () {
    CGFloat _sendAreaWidth;
    CGFloat _attachmentAreaWidth;
    
    TGModernButton *_closeButton;
    UIView *_lineView;
    UILabel *_nameLabel;
    UILabel *_contentLabel;
    TGImageView *_imageView;
    UIImageView *_imageIconView;
    
    NSString *_defaultTitle;
    
    UILabel *_timerLabel;
    STimer *_timer;
    
    NSTimeInterval _editingTimeout;
    UIActivityIndicatorView *_activityIndicator;
}

@end

@implementation TGModernConversationEditingMessageInputPanel

- (NSString *)stickerRepresentation:(TGDocumentMediaAttachment *)fileMedia
{
    __block NSString *stickerRepresentation = @"";
    
    for (id attribute in fileMedia.attributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
        {
            stickerRepresentation = ((TGDocumentAttributeSticker *)attribute).alt;
            break;
        }
    }
    
    return stickerRepresentation;
}

- (instancetype)initWithMessage:(TGMessage *)message
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
        _nameLabel.font = TGSystemFontOfSize(14.5f);
        
        _timerLabel = [[UILabel alloc] init];
        _timerLabel.backgroundColor = nil;
        _timerLabel.opaque = false;
        _timerLabel.font = TGSystemFontOfSize(13.0f);
        _timerLabel.textColor = UIColorRGB(0x86868d);
        [self addSubview:_timerLabel];
        _timerLabel.hidden = true;
        
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = nil;
        _contentLabel.opaque = false;
        _contentLabel.font = TGSystemFontOfSize(14.5f);
        [self addSubview:_contentLabel];
        
        _customTitle = TGLocalized(@"Conversation.EditingMessagePanelTitle");
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)]];
        
        [self updateMessage:message];
        
        int32_t maxChannelMessageEditTime = 60 * 60 * 24 * 2;
        NSData *data = [TGDatabaseInstance() customProperty:@"maxChannelMessageEditTime"];
        if (data.length >= 4) {
            [data getBytes:&maxChannelMessageEditTime length:4];
        }
        _editingTimeout = maxChannelMessageEditTime;
        
        if (message.cid == TGTelegraphInstance.clientUserId) {
            _editingTimeout = 0;
        } else {
            __weak TGModernConversationEditingMessageInputPanel *weakSelf = self;
            _timer = [[STimer alloc] initWithTimeout:1.0 repeat:true completion:^{
                __strong TGModernConversationEditingMessageInputPanel *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf updateTimer];
                }
            } queue:[SQueue mainQueue]];
            [_timer start];
            [self updateTimer];
        }
    }
    return self;
}

- (void)dealloc {
    [_timer invalidate];
}

- (void)updateTimer {
    if (_editingTimeout <= DBL_EPSILON) {
        _timerLabel.hidden = true;
    } else {
        NSTimeInterval remainingTime = _message.date + _editingTimeout - [[TGTelegramNetworking instance] approximateRemoteTime];
        if (remainingTime > 5.0 * 60.0) {
            _timerLabel.hidden = true;
        } else if (remainingTime < 0.0) {
            _timerLabel.hidden = false;
            _timerLabel.text = @"0:00";
            [_timerLabel sizeToFit];
            [self setNeedsLayout];
            
            [_timer invalidate];
        } else {
            _timerLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", ((int)remainingTime) / 60, ((int)remainingTime) % 60];
            [_timerLabel sizeToFit];
            [self setNeedsLayout];
            _timerLabel.hidden = false;
        }
    }
}

- (void)setCustomTitle:(NSString *)customTitle {
    _customTitle = customTitle;
    if (customTitle) {
        _nameLabel.text = customTitle;
    } else {
        _nameLabel.text = _defaultTitle;
    }
    [self setNeedsLayout];
}

- (void)setLargeDismissButton:(bool)largeDismissButton {
    _largeDismissButton = largeDismissButton;
    
    if (largeDismissButton) {
        UIImage *closeImage = [UIImage imageNamed:@"PinnedMessagePanelClose.png"];
        _closeButton.frame = CGRectMake(0.0f, 0.0f, closeImage.size.width, closeImage.size.height);
        [_closeButton setBackgroundImage:closeImage forState:UIControlStateNormal];
    } else {
        UIImage *closeImage = [UIImage imageNamed:@"ReplyPanelClose.png"];
        _closeButton.frame = CGRectMake(0.0f, 0.0f, closeImage.size.width, closeImage.size.height);
        [_closeButton setBackgroundImage:closeImage forState:UIControlStateNormal];
    }
    
    [self setNeedsLayout];
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

- (void)setTitleFont:(UIFont *)titleFont {
    _nameLabel.font = titleFont;
    [self setNeedsLayout];
}

- (void)setLineInsets:(UIEdgeInsets)lineInsets {
    _lineInsets = lineInsets;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [UIView performWithoutAnimation:^
    {
        CGSize boundsSize = CGSizeMake(self.bounds.size.width, [self preferredHeight]);
        
        CGFloat leftPadding = 0.0f;
        if (_imageView != nil)
        {
            leftPadding += 40.0f;
            _imageView.frame = CGRectMake(_attachmentAreaWidth + 12.0f, 6.0f, 35.0f, 35.0f);
            
            _imageIconView.frame = CGRectMake(TGRetinaFloor((_imageView.frame.size.width - _imageIconView.frame.size.width) / 2.0f), TGRetinaFloor((_imageView.frame.size.height - _imageIconView.frame.size.height) / 2.0f), _imageIconView.frame.size.width, _imageIconView.frame.size.height);
        }
        
        if (_activityIndicator != nil) {
            _activityIndicator.frame = CGRectMake(12.0f, CGFloor((self.frame.size.height - _activityIndicator.frame.size.height) / 2.0f) + 4.0f, _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
        }
        
        CGSize nameSize = [_nameLabel.text sizeWithFont:_nameLabel.font];
        nameSize.width = MIN(nameSize.width, boundsSize.width - _attachmentAreaWidth - 40.0f - _sendAreaWidth - leftPadding);
        
        CGSize contentLabelSize = [_contentLabel.text sizeWithFont:_contentLabel.font];
        contentLabelSize.width = MIN(contentLabelSize.width, boundsSize.width - _attachmentAreaWidth - 40.0f - _sendAreaWidth - leftPadding);
        
        if (_largeDismissButton) {
            _closeButton.frame = CGRectMake(boundsSize.width - _sendAreaWidth - _closeButton.frame.size.width, CGFloor((boundsSize.height - _closeButton.frame.size.height) / 2.0f + 4.0f) , _closeButton.frame.size.width, _closeButton.frame.size.height);
        } else {
            _closeButton.frame = CGRectMake(boundsSize.width - _sendAreaWidth - _closeButton.frame.size.width - 4.0f, 11.0f, _closeButton.frame.size.width, _closeButton.frame.size.height);
        }
        _lineView.frame = CGRectMake(_attachmentAreaWidth + 4.0f, 6.0f + _lineInsets.top, 2.0f, boundsSize.height - 6.0f - _lineInsets.top - _lineInsets.bottom);
        _nameLabel.frame = CGRectMake(_attachmentAreaWidth + 16.0f + leftPadding, 5.0f, CGCeil(nameSize.width), CGCeil(nameSize.height));
        _timerLabel.frame = CGRectMake(CGRectGetMaxX(_nameLabel.frame) + 4.0f, _nameLabel.frame.origin.y + 2.0f, _timerLabel.frame.size.width, _timerLabel.frame.size.height);
        _contentLabel.frame = CGRectMake(_attachmentAreaWidth + 16.0f + leftPadding, 24.0f, CGCeil(contentLabelSize.width), CGCeil(contentLabelSize.height));
    }];
}

- (void)updateMessage:(TGMessage *)message {
    [_imageView removeFromSuperview];
    _imageView = nil;
    
    [_imageIconView removeFromSuperview];
    _imageIconView = nil;
    
    _message = message;
    
    UIColor *color = UIColorRGB(0x34a5ff);
    
    NSString *title = @"";
    id author = nil;
    if (TGPeerIdIsChannel(message.cid) && TGMessageSortKeySpace(message.sortKey) == TGMessageSpaceImportant) {
        TGConversation *conversation = [TGDatabaseInstance() loadChannels:@[@(message.cid)]][@(message.cid)];
        author = conversation;
        if (conversation != nil) {
            title = conversation.chatTitle;
        }
    } else {
        TGUser *user = [TGDatabaseInstance() loadUser:(int32_t)message.fromUid];
        author = user;
        title = user.displayName;
    }
    _defaultTitle = title;
    
    if (_customTitle != nil) {
        title = _customTitle;
    }
    
    _nameLabel.textColor = color;
    _nameLabel.text = title;
    [self addSubview:_nameLabel];
    
    SSignal *imageSignal = nil;
    UIImage *imageIcon = nil;
    NSString *text = message.text;
    UIColor *textColor = [UIColor blackColor];
    NSLineBreakMode lineBreakMode = NSLineBreakByTruncatingTail;
    
    UIColor *mediaTextColor = UIColorRGB(0x8c8c92);
    
    for (TGMediaAttachment *attachment in message.mediaAttachments)
    {
        if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
        {
            text = TGLocalized(@"Message.Photo");
            textColor = mediaTextColor;
            
            imageSignal = [TGSharedPhotoSignals squarePhotoThumbnail:(TGImageMediaAttachment *)attachment ofSize:CGSizeMake(35.0f, 35.0f) threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:[TGReplyHeaderModel thumbnailCornerRadius]] downloadLargeImage:true placeholder:nil];
        }
        else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
        {
            text = TGLocalized(@"Message.Video");
            textColor = mediaTextColor;
            
            imageSignal = [TGSharedVideoSignals squareVideoThumbnail:(TGVideoMediaAttachment *)attachment ofSize:CGSizeMake(35.0f, 35.0f) threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:[TGReplyHeaderModel thumbnailCornerRadius]]];
            imageIcon = [UIImage imageNamed:@"ReplyHeaderThumbnailVideoPlay.png"];
        }
        else if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
        {
            text = TGLocalized(@"Message.Audio");
            textColor = mediaTextColor;
        }
        else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
        {
            bool isSticker = false;
            bool isVoice = false;
            for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes)
            {
                if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                {
                    isSticker = true;
                    break;
                }
                else if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                    isVoice = ((TGDocumentAttributeAudio *)attribute).isVoice;
                }
            }
            
            if (isSticker)
            {
                NSString *stickerRepresentation = [self stickerRepresentation:(TGDocumentMediaAttachment *)attachment];
                if (stickerRepresentation.length != 0)
                    text = [[NSString alloc] initWithFormat:@"%@ %@", stickerRepresentation, TGLocalized(@"Message.Sticker")];
                else
                    text = TGLocalized(@"Message.Sticker");
                textColor = mediaTextColor;
            }
            else if ([(TGDocumentMediaAttachment *)attachment isAnimated]) {
                text = TGLocalized(@"Message.Animation");
                textColor = mediaTextColor;
            }
            else if (isVoice) {
                text = TGLocalized(@"Message.Audio");
                textColor = mediaTextColor;
            }
            else
            {
                text = ((TGDocumentMediaAttachment *)attachment).fileName;
                lineBreakMode = NSLineBreakByTruncatingMiddle;
                textColor = mediaTextColor;
            }
        }
        else if ([attachment isKindOfClass:[TGLocationMediaAttachment class]])
        {
            text = TGLocalized(@"Message.Location");
            textColor = mediaTextColor;
        }
        else if ([attachment isKindOfClass:[TGContactMediaAttachment class]])
        {
            text = TGLocalized(@"Message.Contact");
            textColor = mediaTextColor;
        }
        else if ([attachment isKindOfClass:[TGActionMediaAttachment class]])
        {
            text = [TGReplyHeaderActionModel messageTextForActionMedia:(TGActionMediaAttachment *)attachment otherAttachments:message.mediaAttachments author:author];
        }
    }
    
    if (message.messageLifetime > 0 && message.messageLifetime <= 60) {
        imageSignal = nil;
    }
    
    if (imageSignal != nil)
    {
        _imageView = [[TGImageView alloc] init];
        [self addSubview:_imageView];
        
        [_imageView setSignal:imageSignal];
        
        if (imageIcon != nil)
        {
            _imageIconView = [[UIImageView alloc] initWithImage:imageIcon];
            [_imageView addSubview:_imageIconView];
        }
    }
    
    _contentLabel.text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    _contentLabel.textColor = textColor;
    _contentLabel.lineBreakMode = lineBreakMode;
    _contentLabel.numberOfLines = 1;
}


- (void)tapGesture:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (_tap) {
            _tap();
        }
    }
}

- (void)setDisplayProgress:(bool)displayProgress {
    _displayProgress = displayProgress;
    if (_displayProgress) {
        if (_activityIndicator == nil) {
            _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [self addSubview:_activityIndicator];
            [_activityIndicator startAnimating];
            _activityIndicator.alpha = 0.0f;
            [UIView animateWithDuration:0.3 animations:^{
                _activityIndicator.alpha = 1.0f;
            }];
            [self setNeedsLayout];
        }
    } else if (_activityIndicator != nil) {
        UIActivityIndicatorView *activityIndicator = _activityIndicator;
        _activityIndicator = nil;
        [UIView animateWithDuration:0.3 animations:^{
            activityIndicator.alpha = 0.0f;
        } completion:^(__unused BOOL finished) {
            [activityIndicator stopAnimating];
            [activityIndicator removeFromSuperview];
        }];
    }
}

@end
