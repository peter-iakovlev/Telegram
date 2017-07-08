#import "TGModernConversationForwardInputPanel.h"

#import "TGDatabase.h"
#import "TGPeerIdAdapter.h"

#import "TGModernButton.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGStringUtils.h"

typedef enum {
    TGCommonMediaTypeNone,
    TGCommonMediaTypeTexts,
    TGCommonMediaTypePhotos,
    TGCommonMediaTypeVideos,
    TGCommonMediaTypeAudios,
    TGCommonMediaTypeFiles,
    TGCommonMediaTypeStickers,
    TGCommonMediaTypeLocations,
    TGCommonMediaTypeContacts,
    TGCommonMediaTypeGifs,
    TGCommonMediaTypeVideoMessages
} TGCommonMediaType;

@interface TGModernConversationForwardInputPanel ()
{
    CGFloat _sendAreaWidth;
    CGFloat _attachmentAreaWidth;
    
    TGModernButton *_closeButton;
    UIView *_lineView;
    UILabel *_nameLabel;
    UILabel *_contentLabel;
}

@end

@implementation TGModernConversationForwardInputPanel

+ (TGCommonMediaType)commonMediaTypeForMessage:(TGMessage *)message
{
    for (TGMediaAttachment *attachment in message.mediaAttachments)
    {
        if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
            return TGCommonMediaTypePhotos;
        if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
            return TGCommonMediaTypeAudios;
        else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
        {
            if (((TGVideoMediaAttachment *)attachment).roundMessage)
                return TGCommonMediaTypeVideoMessages;
            else
                return TGCommonMediaTypeVideos;
        }
        else if ([attachment isKindOfClass:[TGLocationMediaAttachment class]])
            return TGCommonMediaTypeLocations;
        else if ([attachment isKindOfClass:[TGContactMediaAttachment class]])
            return TGCommonMediaTypeContacts;
        else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
        {
            for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes)
            {
                if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                    return TGCommonMediaTypeStickers;
                else if ([attribute isKindOfClass:[TGDocumentAttributeAnimated class]]) {
                    return TGCommonMediaTypeGifs;
                } else if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                    if (((TGDocumentAttributeAudio *)attribute).isVoice) {
                        return TGCommonMediaTypeAudios;
                    }
                }
            }
            return TGCommonMediaTypeFiles;
        }
    }
    
    return TGCommonMediaTypeTexts;
}

+ (TGCommonMediaType)commonMediaTypeForMessages:(NSArray *)messages
{
    TGCommonMediaType commonType = TGCommonMediaTypeNone;
    bool initialized = false;
    
    for (TGMessage *message in messages)
    {
        TGCommonMediaType currentType = [self commonMediaTypeForMessage:message];
        if (!initialized) {
            commonType = currentType;
            initialized = true;
        }
        else if (commonType != currentType)
            return TGCommonMediaTypeNone;
    }
    
    return commonType;
}

+ (NSString *)formatPrefixForForwardedCommonType:(TGCommonMediaType)commonType
{
    switch (commonType)
    {
        case TGCommonMediaTypeNone:
            return @"ForwardedMessages_";
        case TGCommonMediaTypeTexts:
            return @"ForwardedMessages_";
        case TGCommonMediaTypePhotos:
            return @"ForwardedPhotos_";
        case TGCommonMediaTypeVideos:
            return @"ForwardedVideos_";
        case TGCommonMediaTypeAudios:
            return @"ForwardedAudios_";
        case TGCommonMediaTypeFiles:
            return @"ForwardedFiles_";
        case TGCommonMediaTypeContacts:
            return @"ForwardedContacts_";
        case TGCommonMediaTypeStickers:
            return @"ForwardedStickers_";
        case TGCommonMediaTypeLocations:
            return @"ForwardedLocations_";
        case TGCommonMediaTypeGifs:
            return @"ForwardedGifs_";
        case TGCommonMediaTypeVideoMessages:
            return @"ForwardedVideoMessages_";
    }
}

+ (NSString *)textForMessages:(NSArray *)messages breakInTheMiddle:(bool *)breakInTheMiddle
{
    TGCommonMediaType commonType = [self commonMediaTypeForMessages:messages];
    if (messages.count == 1)
    {
        switch (commonType)
        {
            case TGCommonMediaTypeTexts:
                for (id media in ((TGMessage *)messages[0]).mediaAttachments) {
                    if ([media isKindOfClass:[TGInvoiceMediaAttachment class]]) {
                        return ((TGInvoiceMediaAttachment *)media).title;
                    } else if ([media isKindOfClass:[TGGameMediaAttachment class]]) {
                        return ((TGGameMediaAttachment *)media).title;
                    }
                }
                return ((TGMessage *)messages[0]).text;
            case TGCommonMediaTypeFiles:
            {
                if (breakInTheMiddle)
                    *breakInTheMiddle = true;
                for (id attachment in ((TGMessage *)messages[0]).mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
                        return ((TGDocumentMediaAttachment *)attachment).fileName;
                }
                break;
            }
            default:
                break;
        }
    }
    
    NSString *formatPrefix = [TGStringUtils integerValueFormat:[self formatPrefixForForwardedCommonType:commonType] value:(int)messages.count];
    return [[NSString alloc] initWithFormat:TGLocalized(formatPrefix), [[NSString alloc] initWithFormat:@"%d", (int)messages.count]];
}

+ (NSString *)titleForPeer:(id)peer shortName:(bool)shortName {
    if ([peer isKindOfClass:[TGUser class]]) {
        if (shortName) {
            return ((TGUser *)peer).displayFirstName;
        } else {
            return ((TGUser *)peer).displayName;
        }
    } else if ([peer isKindOfClass:[TGConversation class]]) {
        return ((TGConversation *)peer).chatTitle;
    }
    return @"";
}

+ (NSString *)titleForMessages:(NSArray *)messages
{
    NSMutableArray *peers = [[NSMutableArray alloc] init];
    for (TGMessage *message in messages)
    {
        int64_t peerId = message.fromUid;
        if (message.forwardPeerId != 0) {
            peerId = message.forwardPeerId;
        }
        
        bool found = false;
        for (id peer in peers)
        {
            if ([peer isKindOfClass:[TGUser class]]) {
                if (((TGUser *)peer).uid == peerId) {
                    found = true;
                    break;
                }
            } else if ([peer isKindOfClass:[TGConversation class]]) {
                if (((TGConversation *)peer).conversationId == peerId) {
                    found = true;
                    break;
                }
            }
        }
        
        if (!found)
        {
            if (TGPeerIdIsChannel(peerId)) {
                TGConversation *conversation = [TGDatabaseInstance() loadChannels:@[@(peerId)]][@(peerId)];
                if (conversation != nil) {
                    [peers addObject:conversation];
                }
            } else {
                TGUser *user = [TGDatabaseInstance() loadUser:(int)peerId];
                if (user != nil) {
                    [peers addObject:user];
                }
            }
        }
    }
    
    if (peers.count == 0)
        return @"";
    else if (peers.count == 1)
        return [self titleForPeer:peers[0] shortName:false];
    else if (peers.count == 2)
        return [[NSString alloc] initWithFormat:TGLocalized(@"ForwardedAuthors2"), [self titleForPeer:peers[0] shortName:true], [self titleForPeer:peers[1] shortName:true]];
    else
    {
        NSString *format = [TGStringUtils integerValueFormat:@"ForwardedAuthorsOthers_" value:peers.count - 1];
        return [[NSString alloc] initWithFormat:TGLocalized(format), [self titleForPeer:peers[0] shortName:true], [[NSString alloc] initWithFormat:@"%d", (int)peers.count - 1]];
    }
}

- (instancetype)initWithMessages:(NSArray *)messages
{
    self = [super init];
    if (self != nil)
    {
        _messages = messages;
        
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
        
        _nameLabel.text = [TGModernConversationForwardInputPanel titleForMessages:messages];
        [self addSubview:_nameLabel];
        
        bool breakInTheMiddle = false;
        NSString *text = [TGModernConversationForwardInputPanel textForMessages:messages breakInTheMiddle:&breakInTheMiddle];
        NSLineBreakMode lineBreakMode = breakInTheMiddle ? NSLineBreakByTruncatingMiddle : NSLineBreakByTruncatingTail;
        
        UIColor *mediaTextColor = UIColorRGB(0x8c8c92);
        
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = nil;
        _contentLabel.opaque = false;
        _contentLabel.textColor = mediaTextColor;
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
    return 41.0f;
}

- (void)setSendAreaWidth:(CGFloat)sendAreaWidth attachmentAreaWidth:(CGFloat)attachmentAreaWidth
{
    _sendAreaWidth = sendAreaWidth;
    _attachmentAreaWidth = attachmentAreaWidth;
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
