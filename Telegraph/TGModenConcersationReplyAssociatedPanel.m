#import "TGModenConcersationReplyAssociatedPanel.h"

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

@interface TGModenConcersationReplyAssociatedPanel ()
{
    CGFloat _sendAreaWidth;
    CGFloat _attachmentAreaWidth;
    
    TGModernButton *_closeButton;
    UIView *_wrapperView;
    UIView *_lineView;
    UILabel *_nameLabel;
    UILabel *_contentLabel;
    TGImageView *_imageView;
    UIImageView *_imageIconView;
    
    NSString *_defaultTitle;
}

@end

@implementation TGModenConcersationReplyAssociatedPanel

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
        _closeButton.tag = -1;
        [self addSubview:_closeButton];
        
        _wrapperView = [[UIView alloc] init];
        [self addSubview:_wrapperView];
        
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [_wrapperView addGestureRecognizer:gestureRecognizer];
        
        UIColor *color = UIColorRGB(0x34a5ff);
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = color;
        [_wrapperView addSubview:_lineView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = nil;
        _nameLabel.opaque = false;
        _nameLabel.font = TGSystemFontOfSize(14.5f);
        
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = nil;
        _contentLabel.opaque = false;
        _contentLabel.font = TGSystemFontOfSize(14.5f);
        [_wrapperView addSubview:_contentLabel];
        
        [self updateMessage:message];
    }
    return self;
}

- (void)handleTap:(UITapGestureRecognizer *)__unused gestureRecognizer {
    if (self.pressed != nil)
        self.pressed();
}

- (void)setCustomTitle:(NSString *)customTitle {
    _customTitle = customTitle;
    if (customTitle) {
        _nameLabel.text = customTitle;
    } else {
        _nameLabel.text = _defaultTitle;
    }
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
        
        _wrapperView.frame = CGRectMake(_attachmentAreaWidth, 0.0f, boundsSize.width - _attachmentAreaWidth - 40.0f - _sendAreaWidth, boundsSize.height);
        
        CGFloat leftPadding = 0.0f;
        if (_imageView != nil)
        {
            leftPadding += 40.0f;
            _imageView.frame = CGRectMake(12.0f, 6.0f, 35.0f, 35.0f);
            
            _imageIconView.frame = CGRectMake(TGRetinaFloor((_imageView.frame.size.width - _imageIconView.frame.size.width) / 2.0f), TGRetinaFloor((_imageView.frame.size.height - _imageIconView.frame.size.height) / 2.0f), _imageIconView.frame.size.width, _imageIconView.frame.size.height);
        }
        
        CGSize nameSize = [_nameLabel.text sizeWithFont:_nameLabel.font];
        nameSize.width = MIN(nameSize.width, boundsSize.width - _attachmentAreaWidth - 40.0f - _sendAreaWidth - leftPadding);
        
        CGSize contentLabelSize = [_contentLabel.text sizeWithFont:_contentLabel.font];
        contentLabelSize.width = MIN(contentLabelSize.width, boundsSize.width - _attachmentAreaWidth - 40.0f - _sendAreaWidth - leftPadding);
        
        if (_largeDismissButton) {
            _closeButton.frame = CGRectMake(boundsSize.width - _sendAreaWidth - _closeButton.frame.size.width, CGFloor((boundsSize.height - _closeButton.frame.size.height) / 2.0f + 4.0f) , _closeButton.frame.size.width, _closeButton.frame.size.height);
        } else {
            _closeButton.frame = CGRectMake(boundsSize.width - _sendAreaWidth - _closeButton.frame.size.width - 7.0f, 11.0f, _closeButton.frame.size.width, _closeButton.frame.size.height);
        }
        _lineView.frame = CGRectMake(4.0f, 6.0f + _lineInsets.top, 2.0f, boundsSize.height - 6.0f - _lineInsets.top - _lineInsets.bottom);
        _nameLabel.frame = CGRectMake(16.0f + leftPadding, 5.0f, CGCeil(nameSize.width), CGCeil(nameSize.height));
        _contentLabel.frame = CGRectMake(16.0f + leftPadding, 24.0f, CGCeil(contentLabelSize.width), CGCeil(contentLabelSize.height));
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
    [_wrapperView addSubview:_nameLabel];
    
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
            TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
            if (imageAttachment.caption.length > 0)
                text = imageAttachment.caption;
            else
                text = TGLocalized(@"Message.Photo");
            textColor = mediaTextColor;
            
            imageSignal = [TGSharedPhotoSignals squarePhotoThumbnail:(TGImageMediaAttachment *)attachment ofSize:CGSizeMake(35.0f, 35.0f) threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:[TGReplyHeaderModel thumbnailCornerRadius]] downloadLargeImage:true placeholder:nil];
        }
        else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
        {
            TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
            if (videoAttachment.caption.length > 0)
                text = videoAttachment.caption;
            else
                text = videoAttachment.roundMessage ? TGLocalized(@"Message.VideoMessage") : TGLocalized(@"Message.Video");
            CGFloat cornerRadius = videoAttachment.roundMessage ? 17.5f * TGScreenScaling() : [TGReplyHeaderModel thumbnailCornerRadius];
            textColor = mediaTextColor;
            
            imageSignal = [TGSharedVideoSignals squareVideoThumbnail:(TGVideoMediaAttachment *)attachment ofSize:CGSizeMake(35.0f, 35.0f) threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:cornerRadius]];
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
            bool isMusic = false;
            TGDocumentAttributeAudio *audioAttribute = nil;
            for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes)
            {
                if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                {
                    isSticker = true;
                    break;
                }
                else if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                    audioAttribute = (TGDocumentAttributeAudio *)attribute;
                    isVoice = audioAttribute.isVoice;
                    isMusic = !isVoice;
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
                
                TGDocumentMediaAttachment *document = (TGDocumentMediaAttachment *)attachment;
                if (document.thumbnailInfo != nil) {
                    TGImageMediaAttachment *imageMedia = [[TGImageMediaAttachment alloc] init];
                    imageMedia.imageInfo = document.thumbnailInfo;
                    imageSignal = [TGSharedPhotoSignals squarePhotoThumbnail:imageMedia ofSize:CGSizeMake(35.0f, 35.0f) threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:[TGReplyHeaderModel thumbnailCornerRadius]] downloadLargeImage:true placeholder:nil];
                }
            }
            else if (isVoice) {
                text = TGLocalized(@"Message.Audio");
                textColor = mediaTextColor;
            }
            else if (isMusic) {
                NSString *title = ((TGDocumentMediaAttachment *)attachment).fileName;
                if (audioAttribute.title.length > 0)
                {
                    title = audioAttribute.title;
                    
                    if (audioAttribute.performer.length > 0)
                        title = [NSString stringWithFormat:@"%@ — %@", audioAttribute.performer, title];
                }
                
                text = title;
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
        else if ([attachment isKindOfClass:[TGGameMediaAttachment class]]) {
            text = ((TGGameMediaAttachment *)attachment).title;
            textColor = mediaTextColor;
            
            TGGameMediaAttachment *gameMedia = (TGGameMediaAttachment *)attachment;
            if (gameMedia.photo != nil) {
                imageSignal = [TGSharedPhotoSignals squarePhotoThumbnail:gameMedia.photo ofSize:CGSizeMake(35.0f, 35.0f) threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:[TGReplyHeaderModel thumbnailCornerRadius]] downloadLargeImage:true placeholder:nil];
            } else if (gameMedia.document != nil && gameMedia.document.thumbnailInfo != nil) {
                TGImageMediaAttachment *imageMedia = [[TGImageMediaAttachment alloc] init];
                imageMedia.imageInfo = gameMedia.document.thumbnailInfo;
                imageSignal = [TGSharedPhotoSignals squarePhotoThumbnail:imageMedia ofSize:CGSizeMake(35.0f, 35.0f) threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:[TGReplyHeaderModel thumbnailCornerRadius]] downloadLargeImage:true placeholder:nil];
            }
        }
        else if ([attachment isKindOfClass:[TGInvoiceMediaAttachment class]]) {
            text = ((TGInvoiceMediaAttachment *)attachment).title;
            textColor = mediaTextColor;
        }
    }
    
    if (message.messageLifetime > 0 && message.messageLifetime <= 60) {
        imageSignal = nil;
    }
    
    if (imageSignal != nil)
    {
        _imageView = [[TGImageView alloc] init];
        [_wrapperView addSubview:_imageView];
        
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

@end
