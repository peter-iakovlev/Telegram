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
    UIView *_lineView;
    UILabel *_nameLabel;
    UILabel *_contentLabel;
    TGImageView *_imageView;
    UIImageView *_imageIconView;
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
        _message = message;
        
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
        
        NSString *title = @"";
        id author = nil;
        if (TGPeerIdIsChannel(message.fromUid)) {
            TGConversation *conversation = [TGDatabaseInstance() loadChannels:@[@(message.fromUid)]][@(message.fromUid)];
            author = conversation;
            if (conversation != nil) {
                title = conversation.chatTitle;
            }
        } else {
            TGUser *user = [TGDatabaseInstance() loadUser:(int32_t)message.fromUid];
            author = user;
            title = user.displayName;
        }
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = nil;
        _nameLabel.opaque = false;
        _nameLabel.textColor = color;
        _nameLabel.font = TGSystemFontOfSize(14.5f);
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
                
                imageSignal = [TGSharedPhotoSignals squarePhotoThumbnail:(TGImageMediaAttachment *)attachment ofSize:CGSizeMake(35.0f, 35.0f) threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:[TGReplyHeaderModel thumbnailCornerRadius]] downloadLargeImage:false placeholder:nil];
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
                for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes)
                {
                    if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                    {
                        isSticker = true;
                        break;
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
                text = [TGReplyHeaderActionModel messageTextForActionMedia:(TGActionMediaAttachment *)attachment author:author];
            }
        }
        
        if (imageSignal != nil)
        {
            _imageView = [[TGImageView alloc] init];
            [_imageView setSignal:imageSignal];
            [self addSubview:_imageView];
            
            if (imageIcon != nil)
            {
                _imageIconView = [[UIImageView alloc] initWithImage:imageIcon];
                [_imageView addSubview:_imageIconView];
            }
        }
        
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = nil;
        _contentLabel.opaque = false;
        _contentLabel.textColor = textColor;
        _contentLabel.font = TGSystemFontOfSize(14.5f);
        _contentLabel.text = text;
        _contentLabel.lineBreakMode = lineBreakMode;
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
    return 39.0f;
}

- (void)setSendAreaWidth:(CGFloat)sendAreaWidth attachmentAreaWidth:(CGFloat)attachmentAreaWidth
{
    _sendAreaWidth = sendAreaWidth;
    _attachmentAreaWidth = attachmentAreaWidth;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize boundsSize = CGSizeMake(self.bounds.size.width, [self preferredHeight]);
    
    CGFloat leftPadding = 0.0f;
    if (_imageView != nil)
    {
        leftPadding += 40.0f;
        _imageView.frame = CGRectMake(_attachmentAreaWidth + 12.0f, 7.0f, 35.0f, 35.0f);
        
        _imageIconView.frame = CGRectMake(TGRetinaFloor((_imageView.frame.size.width - _imageIconView.frame.size.width) / 2.0f), TGRetinaFloor((_imageView.frame.size.height - _imageIconView.frame.size.height) / 2.0f), _imageIconView.frame.size.width, _imageIconView.frame.size.height);
    }
    
    CGSize nameSize = [_nameLabel.text sizeWithFont:_nameLabel.font];
    nameSize.width = MIN(nameSize.width, boundsSize.width - _attachmentAreaWidth - 40.0f - _sendAreaWidth - leftPadding);
    
    CGSize contentLabelSize = [_contentLabel.text sizeWithFont:_contentLabel.font];
    contentLabelSize.width = MIN(contentLabelSize.width, boundsSize.width - _attachmentAreaWidth - 40.0f - _sendAreaWidth - leftPadding);
    
    _closeButton.frame = CGRectMake(boundsSize.width - _sendAreaWidth - _closeButton.frame.size.width - 7.0f, 12.0f, _closeButton.frame.size.width, _closeButton.frame.size.height);
    _lineView.frame = CGRectMake(_attachmentAreaWidth + 4.0f, 7.0f, 2.0f, boundsSize.height - 7.0f + 3.0f);
    _nameLabel.frame = CGRectMake(_attachmentAreaWidth + 16.0f + leftPadding, 5.0f, CGCeil(nameSize.width), CGCeil(nameSize.height));
    _contentLabel.frame = CGRectMake(_attachmentAreaWidth + 16.0f + leftPadding, 24.0f, CGCeil(contentLabelSize.width), CGCeil(contentLabelSize.height));
}

@end
