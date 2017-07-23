/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGContentBubbleViewModel.h"

#import "TGMessage.h"
#import "TGUser.h"
#import "TGConversation.h"
#import "TGPeerIdAdapter.h"

#import "TGImageUtils.h"
#import "TGDateUtils.h"
#import "TGStringUtils.h"

#import "TGTelegraphConversationMessageAssetsSource.h"
#import "TGReusableLabel.h"
#import "TGModernConversationItem.h"

#import "TGTextMessageBackgroundViewModel.h"
#import "TGModernFlatteningViewModel.h"
#import "TGModernDateViewModel.h"
#import "TGModernClockProgressViewModel.h"
#import "TGModernTextViewModel.h"

#import "TGModernView.h"

#import "TGDoubleTapGestureRecognizer.h"

#import "TGReplyHeaderTextModel.h"
#import "TGReplyHeaderPhotoModel.h"
#import "TGReplyHeaderVideoModel.h"
#import "TGReplyHeaderAudioModel.h"
#import "TGReplyHeaderFileModel.h"
#import "TGReplyHeaderContactModel.h"
#import "TGReplyHeaderLocationModel.h"
#import "TGReplyHeaderStickerModel.h"
#import "TGReplyHeaderActionModel.h"

#import "TGArticleWebpageFooterModel.h"

#import "TGMessageViewsViewModel.h"
#import "TGModernButtonViewModel.h"
#import "TGModernButtonView.h"

#import "TGTextCheckingResult.h"

#import "TGFont.h"

#import "TGMessageReplyButtonsModel.h"

#import "TGDocumentWebpageFooterModel.h"
#import "TGAudioWebpageFooterModel.h"
#import "TGMusicWebpageFooterModel.h"
#import "TGStickerWebpageFooterModel.h"
#import "TGRoundVideoWebpageFooterModel.h"

bool debugShowMessageIds = false;

@interface TGContentBubbleViewModel () <UIGestureRecognizerDelegate, TGDoubleTapGestureRecognizerDelegate>
{
    UITapGestureRecognizer *_unsentButtonTapRecognizer;
    TGDoubleTapGestureRecognizer *_boundDoubleTapRecognizer;
    
    TGModernImageViewModel *_broadcastIconModel;
    CGPoint _itemPosition;
    
    TGModernButtonViewModel *_shareButtonModel;
    TGBotReplyMarkup *_replyMarkup;
    
    bool _boundToContainer;
    bool _mediaIsAvailable;
    bool _mediaProgressVisible;
    float _mediaProgress;
    
    TGMessageReplyButtonsModel *_replyButtonsModel;
    SMetaDisposable *_callbackButtonInProgressDisposable;
    NSDictionary *_callbackButtonInProgress;
    
    TGMessage *_message;
    
    bool _hasInvoice;
}

@end

@implementation TGContentBubbleViewModel

+ (void)debugEnableShowMessageIds
{
    debugShowMessageIds = true;
}

- (instancetype)initWithMessage:(TGMessage *)message authorPeer:(id)authorPeer viaUser:(TGUser *)viaUser context:(TGModernViewContext *)context
{
    self = [super initWithAuthorPeer:authorPeer context:context];
    if (self != nil)
    {
        _callbackButtonInProgressDisposable = [[SMetaDisposable alloc] init];
        
        static TGTelegraphConversationMessageAssetsSource *assetsSource = nil;
        
        static UIColor *incomingDateColor = nil;
        static UIColor *outgoingDateColor = nil;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            assetsSource = [TGTelegraphConversationMessageAssetsSource instance];
            
            incomingDateColor = UIColorRGBA(0x525252, 0.6f);
            outgoingDateColor = UIColorRGBA(0x008c09, 0.8f);
        });
        
        _needsEditingCheckButton = true;
        
        bool isChannel = [authorPeer isKindOfClass:[TGConversation class]];
        
        _message = message;
        _mid = message.mid;
        _incoming = !message.outgoing;
        _incomingAppearance = _incoming || isChannel;
        _deliveryState = message.deliveryState;
        
        _read = ![_context isMessageUnread:message];
        _date = (int32_t)message.date;
        _messageViews = message.viewCount;
        
        _backgroundModel = [[TGTextMessageBackgroundViewModel alloc] initWithType:_incomingAppearance ? TGTextMessageBackgroundIncoming : TGTextMessageBackgroundOutgoing];
        _backgroundModel.blendMode = kCGBlendModeCopy;
        _backgroundModel.skipDrawInContext = true;
        [self addSubmodel:_backgroundModel];
        
        _contentModel = [[TGModernFlatteningViewModel alloc] initWithContext:_context];
        _contentModel.allowSpecialUserInteraction = true;
        _contentModel.viewUserInteractionDisabled = true;
        [self addSubmodel:_contentModel];
        
        if (authorPeer != nil)
        {
            NSString *title = @"";
            if ([authorPeer isKindOfClass:[TGUser class]]) {
                title = ((TGUser *)authorPeer).displayName;
            } else if ([authorPeer isKindOfClass:[TGConversation class]]) {
                title = ((TGConversation *)authorPeer).chatTitle;
            }
            _authorNameModel = [[TGModernTextViewModel alloc] initWithText:title font:[assetsSource messageAuthorNameFont]];
            [_contentModel addSubmodel:_authorNameModel];
            
            if ([authorPeer isKindOfClass:[TGUser class]]) {
                _hasAvatar = true;
            } else if ([authorPeer isKindOfClass:[TGConversation class]]) {
                if ([context isAdminLog]) {
                    _hasAvatar = true;
                }
            }
            
            static CTFontRef dateFont = NULL;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                if (iosMajorVersion() >= 7) {
                    dateFont = CTFontCreateWithFontDescriptor((__bridge CTFontDescriptorRef)[TGItalicSystemFontOfSize(12.0f) fontDescriptor], 0.0f, NULL);
                } else {
                    UIFont *font = TGItalicSystemFontOfSize(12.0f);
                    dateFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, nil);
                }
            });
            _authorSignatureModel = [[TGModernTextViewModel alloc] initWithText:@"" font:dateFont];
            _authorSignatureModel.ellipsisString = @"\u2026,";
            _authorSignatureModel.textColor = _incomingAppearance ? incomingDateColor : outgoingDateColor;
            [_contentModel addSubmodel:_authorSignatureModel];
        }
        
        if (viaUser != nil && viaUser.userName.length != 0) {
            NSString *formatString = TGLocalized(@"Conversation.MessageViaUser");
            NSString *viaUserName = [@"@" stringByAppendingString:viaUser.userName];
            NSRange range = [formatString rangeOfString:@"%@"];
            
            _viaUserModel = [[TGModernTextViewModel alloc] initWithText:[[NSString alloc] initWithFormat:formatString, viaUserName] font:[assetsSource messageAuthorNameFont]];
            if (range.location != NSNotFound) {
                _viaUserModel.textCheckingResults = @[[[TGTextCheckingResult alloc] initWithRange:NSMakeRange(range.location, viaUserName.length) type:TGTextCheckingResultTypeBold contents:nil]];
            }
            _viaUserModel.textColor = _incomingAppearance ? TGAccentColor() : UIColorRGB(0x00a700);
            [_contentModel addSubmodel:_viaUserModel];
            
            _viaUser = viaUser;
        }
        
        bool isBot = false;
        if ([authorPeer isKindOfClass:[TGUser class]]) {
            if (((TGUser *)authorPeer).kind == TGUserKindBot || ((TGUser *)authorPeer).kind ==  TGUserKindSmartBot) {
                isBot = true;
            }
        }
        
        bool hasGameAction = false;
        bool hasPayAction = false;
        TGBotReplyMarkup *replyMarkup = message.replyMarkup;
        if (replyMarkup != nil && replyMarkup.isInline) {
            for (TGBotReplyMarkupRow *row in replyMarkup.rows) {
                for (TGBotReplyMarkupButton *button in row.buttons) {
                    if ([button.action isKindOfClass:[TGBotReplyMarkupButtonActionGame class]]) {
                        hasGameAction = true;
                    }
                    if ([button.action isKindOfClass:[TGBotReplyMarkupButtonActionPurchase class]]) {
                        hasPayAction = true;
                    }
                }
            }
        }
        
        if (_incomingAppearance && (isChannel || _context.isBot || isBot || _context.isPublicGroup || hasGameAction || hasPayAction) && !_context.isAdminLog) {
            [_backgroundModel setPartialMode:false];
            
            _shareButtonModel = [[TGModernButtonViewModel alloc] init];
            _shareButtonModel.image = [[TGTelegraphConversationMessageAssetsSource instance] systemShareButton];
            _shareButtonModel.modernHighlight = true;
            _shareButtonModel.frame = CGRectMake(0.0f, 0.0f, 29.0f, 29.0f);
            if (!isChannel && !hasGameAction) {
                _shareButtonModel.hidden = true;
            }
            [self addSubmodel:_shareButtonModel];
        }
        
        int daytimeVariant = 0;
        NSString *dateText = [TGDateUtils stringForShortTime:(int)message.date daytimeVariant:&daytimeVariant];
        if (debugShowMessageIds) {
            dateText = [[NSString alloc] initWithFormat:@"%d", message.mid];
        }
        _dateModel = [[TGModernDateViewModel alloc] initWithText:dateText textColor:_incomingAppearance ? incomingDateColor : outgoingDateColor daytimeVariant:daytimeVariant];
        [_contentModel addSubmodel:_dateModel];
        
        if (message.isEdited && !(context.isBot || ([_authorPeer isKindOfClass:[TGUser class]] && ((TGUser *)_authorPeer).kind != TGUserKindGeneric))) {/* && (_authorPeer == nil || (![_authorPeer isKindOfClass:[TGConversation class]]) || ((TGConversation *)_authorPeer).isChannel || ((TGConversation *)_authorPeer).isChannelGroup)) {*/
            static CTFontRef dateFont = NULL;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                if (iosMajorVersion() >= 7) {
                    dateFont = CTFontCreateWithFontDescriptor((__bridge CTFontDescriptorRef)[TGItalicSystemFontOfSize(11.0f) fontDescriptor], 0.0f, NULL);
                } else {
                    UIFont *font = TGItalicSystemFontOfSize(11.0f);
                    dateFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, nil);
                }
            });
            _editedLabelModel = [[TGModernLabelViewModel alloc] initWithText:TGLocalized(@"Conversation.MessageEditedLabel") textColor:_dateModel.textColor font:dateFont maxWidth:CGFLOAT_MAX];
            [_contentModel addSubmodel:_editedLabelModel];
        }
        
        if (message.isBroadcast)
        {
            _broadcastIconModel = [[TGModernImageViewModel alloc] initWithImage:[UIImage imageNamed:@"ModernMessageBroadcastIcon.png"]];
            [_broadcastIconModel sizeToFit];
            [_contentModel addSubmodel:_broadcastIconModel];
        }
        
        if (!_incoming && !_inhibitChecks)
        {
            static UIImage *checkPartialImage = nil;
            static UIImage *checkCompleteImage = nil;
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                checkPartialImage = [UIImage imageNamed:@"ModernMessageCheckmark2.png"];
                checkCompleteImage = [UIImage imageNamed:@"ModernMessageCheckmark1.png"];
            });
            
            _checkFirstModel = [[TGModernImageViewModel alloc] initWithImage:checkCompleteImage];
            _checkSecondModel = [[TGModernImageViewModel alloc] initWithImage:checkPartialImage];
            
            if (_deliveryState == TGMessageDeliveryStatePending)
            {
                _progressModel = [[TGModernClockProgressViewModel alloc] initWithType:_incomingAppearance ? TGModernClockProgressTypeIncomingClock : TGModernClockProgressTypeOutgoingClock];
                [self addSubmodel:_progressModel];
                
                if (!_incomingAppearance) {
                    [self addSubmodel:_checkFirstModel];
                    [self addSubmodel:_checkSecondModel];
                }
                _checkFirstModel.alpha = 0.0f;
                _checkSecondModel.alpha = 0.0f;
            }
            else if (_deliveryState == TGMessageDeliveryStateFailed)
            {
                [self addSubmodel:[self unsentButtonModel]];
            }
            else if (_deliveryState == TGMessageDeliveryStateDelivered)
            {
                if (!_incomingAppearance) {
                    [_contentModel addSubmodel:_checkFirstModel];
                }
                _checkFirstEmbeddedInContent = true;
                
                if (_read)
                {
                    if (!_incomingAppearance) {
                        [_contentModel addSubmodel:_checkSecondModel];
                    }
                    _checkSecondEmbeddedInContent = true;
                }
                else
                {
                    if (!_incomingAppearance) {
                        [self addSubmodel:_checkSecondModel];
                    }
                    _checkSecondModel.alpha = 0.0f;
                }
            }
        }
        
        if (_messageViews != nil) {
            _messageViewsModel = [[TGMessageViewsViewModel alloc] init];
            _messageViewsModel.type = _incomingAppearance ? TGMessageViewsViewTypeIncoming : TGMessageViewsViewTypeOutgoing;
            _messageViewsModel.count = _messageViews.viewCount;
            [self addSubmodel:_messageViewsModel];
            _messageViewsModel.hidden = _deliveryState != TGMessageDeliveryStateDelivered;
            [_messageViewsModel sizeToFit];
        }
        
        if (replyMarkup != nil && replyMarkup.isInline) {
            _replyMarkup = replyMarkup;
            _replyButtonsModel = [[TGMessageReplyButtonsModel alloc] init];
            __weak TGContentBubbleViewModel *weakSelf = self;
            _replyButtonsModel.buttonActivated = ^(TGBotReplyMarkupButton *button, NSInteger index) {
                __strong TGContentBubbleViewModel *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{@"mid": @(strongSelf->_mid), @"command": button.text}];
                    if (button.action != nil) {
                        dict[@"action"] = button.action;
                    }
                    dict[@"index"] = @(index);
                    [strongSelf->_context.companionHandle requestAction:@"activateCommand" options:dict];
                }
            };
            
            bool hasReceipt = false;
            if (hasPayAction) {
                for (TGMediaAttachment *media in message.mediaAttachments) {
                    if (media.type == TGInvoiceMediaAttachmentType) {
                        hasReceipt = ((TGInvoiceMediaAttachment *)media).receiptMessageId != 0;
                        break;
                    }
                }
            }
            [_replyButtonsModel setReplyMarkup:replyMarkup hasReceipt:hasReceipt];
            [self addSubmodel:_replyButtonsModel];
        }
    }
    return self;
}

- (void)dealloc {
    [_callbackButtonInProgressDisposable dispose];
}

- (void)setTemporaryHighlighted:(bool)temporaryHighlighted viewStorage:(TGModernViewStorage *)__unused viewStorage
{
    if (temporaryHighlighted)
        [_backgroundModel setHighlightedIfBound];
    else
        [_backgroundModel clearHighlight];
}

- (void)setAuthorNameColor:(UIColor *)authorNameColor
{
    _authorNameModel.textColor = authorNameColor;
}

- (void)setAuthorSignature:(NSString *)authorSignature {
    _authorSignatureModel.text = [authorSignature stringByAppendingString:@","];
    _authorSignature = authorSignature;
}

- (void)setForwardHeader:(id)forwardPeer forwardAuthor:(id)forwardAuthor messageId:(int32_t)messageId forwardSignature:(NSString *)forwardSignature
{
    if (_forwardedHeaderModel == nil)
    {
        static UIColor *incomingForwardColor = nil;
        static UIColor *outgoingForwardColor = nil;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            incomingForwardColor = UIColorRGBA(0x007bff, 1.0f);
            outgoingForwardColor = UIColorRGBA(0x00a516, 1.0f);
        });
        
        static NSRange formatNameRange;
        
        static int localizationVersion = -1;
        if (localizationVersion != TGLocalizedStaticVersion)
            formatNameRange = [TGLocalized(@"Message.ForwardedMessage") rangeOfString:@"%@"];

        _forwardedMessageId = messageId;
        NSString *authorName = @"";
        if ([forwardPeer isKindOfClass:[TGUser class]]) {
            _forwardedPeerId = ((TGUser *)forwardPeer).uid;
            authorName = ((TGUser *)forwardPeer).displayName;
        } else if ([forwardPeer isKindOfClass:[TGConversation class]]) {
            _forwardedPeerId = ((TGConversation *)forwardPeer).conversationId;
            authorName = ((TGConversation *)forwardPeer).chatTitle;
        }
        
        if ([forwardAuthor isKindOfClass:[TGUser class]]) {
            authorName = [[NSString alloc] initWithFormat:@"%@ (%@)", authorName, ((TGUser *)forwardAuthor).displayName];
        } else if (forwardSignature != nil) {
            authorName = [[NSString alloc] initWithFormat:@"%@ (%@)", authorName, forwardSignature];
        }
        
        NSMutableArray *additionalAttributes = [[NSMutableArray alloc] init];
        NSMutableArray *textCheckingResults = [[NSMutableArray alloc] init];

        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageForwardNameFont], (NSString *)kCTFontAttributeName, nil];
        
        NSString *text = [[NSString alloc] initWithFormat:TGLocalized(@"Message.ForwardedMessage"), authorName];
        if (_viaUser != nil && _viaUser.userName.length != 0) {
            NSString *formatString = [@" " stringByAppendingString:TGLocalized(@"Conversation.MessageViaUser")];
            NSString *viaUserName = [@"@" stringByAppendingString:_viaUser.userName];
            NSRange range = [formatString rangeOfString:@"%@"];
            NSString *finalString = [[NSString alloc] initWithFormat:formatString, viaUserName];
            
            if (range.location != NSNotFound) {
                range.location += text.length;
                range.length = viaUserName.length;
                [textCheckingResults addObject:[[TGTextCheckingResult alloc] initWithRange:range type:TGTextCheckingResultTypeLink contents:@"via"]];
                [textCheckingResults addObject:[[TGTextCheckingResult alloc] initWithRange:range type:TGTextCheckingResultTypeUltraBold contents:nil]];
            }
            
            text = [text stringByAppendingString:finalString];
        }
        
        _forwardedHeaderModel = [[TGModernTextViewModel alloc] initWithText:text font:[[TGTelegraphConversationMessageAssetsSource instance] messageForwardTitleFont]];
        _forwardedHeaderModel.textColor = _incomingAppearance ? incomingForwardColor : outgoingForwardColor;
        _forwardedHeaderModel.layoutFlags = TGReusableLabelLayoutMultiline;
        if (formatNameRange.location != NSNotFound && authorName.length != 0)
        {
            NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
            [additionalAttributes addObjectsFromArray:@[[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes]];
        }
        
        _forwardedHeaderModel.additionalAttributes = additionalAttributes;
        _forwardedHeaderModel.textCheckingResults = textCheckingResults;
        
        [_contentModel addSubmodel:_forwardedHeaderModel];
        
        if (_incomingAppearance && [forwardPeer isKindOfClass:[TGConversation class]]) {
            TGConversation *conversation = forwardPeer;
            if (conversation.isChannel && !conversation.isChannelGroup) {
                if (_shareButtonModel == nil) {
                    _shareButtonModel = [[TGModernButtonViewModel alloc] init];
                    _shareButtonModel.image = [[TGTelegraphConversationMessageAssetsSource instance] systemShareButton];
                    _shareButtonModel.modernHighlight = true;
                    _shareButtonModel.frame = CGRectMake(0.0f, 0.0f, 29.0f, 29.0f);
                    [self addSubmodel:_shareButtonModel];
                }
                
                _shareButtonModel.hidden = false;
            }
        }
    }
    
    if (_viaUserModel != nil) {
        [_contentModel removeSubmodel:_viaUserModel viewStorage:nil];
        _viaUserModel = nil;
    }
}

+ (TGReplyHeaderModel *)replyHeaderModelFromMessage:(TGMessage *)replyHeader peer:(id)peer incoming:(bool)incoming system:(bool)system
{
    bool isSecret = replyHeader.messageLifetime > 0 && replyHeader.messageLifetime <= 60;
    for (id attachment in replyHeader.mediaAttachments)
    {
        if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
        {
            return [[TGReplyHeaderPhotoModel alloc] initWithPeer:peer imageMedia:isSecret ? nil : (TGImageMediaAttachment *)attachment incoming:incoming system:system];
        }
        else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
        {
            return [[TGReplyHeaderVideoModel alloc] initWithPeer:peer videoMedia:isSecret ? nil : (TGVideoMediaAttachment *)attachment incoming:incoming system:system];
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
                return [[TGReplyHeaderStickerModel alloc] initWithPeer:peer fileMedia:(TGDocumentMediaAttachment *)attachment incoming:incoming system:system];
            }
            else
            {
                return [[TGReplyHeaderFileModel alloc] initWithPeer:peer fileMedia:(TGDocumentMediaAttachment *)attachment incoming:incoming system:system];
            }
        }
        else if ([attachment isKindOfClass:[TGLocationMediaAttachment class]])
        {
            return [[TGReplyHeaderLocationModel alloc] initWithPeer:peer latitude:((TGLocationMediaAttachment *)attachment).latitude longitude:((TGLocationMediaAttachment *)attachment).longitude incoming:incoming system:system];
        }
        else if ([attachment isKindOfClass:[TGContactMediaAttachment class]])
        {
            return [[TGReplyHeaderContactModel alloc] initWithPeer:peer incoming:incoming system:system];
        }
        else if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
        {
            return [[TGReplyHeaderAudioModel alloc] initWithPeer:peer audioMedia:(TGAudioMediaAttachment *)attachment incoming:incoming system:system];
        }
        else if ([attachment isKindOfClass:[TGActionMediaAttachment class]])
        {
            return [[TGReplyHeaderActionModel alloc] initWithPeer:peer actionMedia:(TGActionMediaAttachment *)attachment otherAttachments:replyHeader.mediaAttachments incoming:incoming system:system];
        }
        else if ([attachment isKindOfClass:[TGGameMediaAttachment class]]) {
            TGGameMediaAttachment *gameMedia = (TGGameMediaAttachment *)attachment;
            if (gameMedia.photo != nil) {
                return [[TGReplyHeaderPhotoModel alloc] initWithPeer:peer imageMedia:gameMedia.photo incoming:incoming system:system caption:gameMedia.title];
            } else if (gameMedia.document != nil) {
                return [[TGReplyHeaderFileModel alloc] initWithPeer:peer fileMedia:gameMedia.document incoming:incoming system:system caption:gameMedia.title];
            } else {
                return [[TGReplyHeaderTextModel alloc] initWithPeer:peer text:((TGGameMediaAttachment *)attachment).title incoming:incoming system:system];
            }
        } else if ([attachment isKindOfClass:[TGInvoiceMediaAttachment class]]) {
            TGWebPageMediaAttachment *invoiceMedia = [(TGInvoiceMediaAttachment *)attachment webpage];
            if (invoiceMedia.photo != nil) {
                return [[TGReplyHeaderPhotoModel alloc] initWithPeer:peer imageMedia:invoiceMedia.photo incoming:incoming system:system caption:invoiceMedia.title];
            } else if (invoiceMedia.document != nil) {
                return [[TGReplyHeaderFileModel alloc] initWithPeer:peer fileMedia:invoiceMedia.document incoming:incoming system:system caption:invoiceMedia.title];
            } else {
                return [[TGReplyHeaderTextModel alloc] initWithPeer:peer text:((TGInvoiceMediaAttachment *)attachment).title incoming:incoming system:system];
            }
        } else if ([attachment isKindOfClass:[TGInvoiceMediaAttachment class]]) {
            TGInvoiceMediaAttachment *invoiceMedia = (TGInvoiceMediaAttachment *)attachment;
            return [[TGReplyHeaderTextModel alloc] initWithPeer:peer text:invoiceMedia.title incoming:incoming system:system];
        }
    }
    
    return [[TGReplyHeaderTextModel alloc] initWithPeer:peer text:replyHeader.text incoming:incoming system:system];
}

- (void)setReplyHeader:(TGMessage *)replyHeader peer:(id)peer
{
    _replyHeaderModel = [TGContentBubbleViewModel replyHeaderModelFromMessage:replyHeader peer:peer incoming:_incomingAppearance system:false];
    if (_replyHeaderModel != nil)
        [_contentModel addSubmodel:_replyHeaderModel];
    _replyMessageId = replyHeader.mid;
}

- (void)setWebPageFooter:(TGWebPageMediaAttachment *)webPage invoice:(TGInvoiceMediaAttachment *)invoice viewStorage:(TGModernViewStorage *)viewStorage
{
    _webPage = webPage;
    if (webPage.url.length == 0 && ![webPage.pageType isEqualToString:@"game"] && ![webPage.pageType isEqualToString:@"invoice"] && ![webPage.pageType isEqualToString:@"message"])
    {
    }
    else
    {
        bool isAnimationOrVideo = false;
        bool imageInText = true;
        if ([webPage.pageType isEqualToString:@"photo"] || [webPage.pageType isEqualToString:@"video"] || [webPage.pageType isEqualToString:@"gif"] || [webPage.pageType isEqualToString:@"game"] || [webPage.pageType isEqualToString:@"invoice"] || [webPage.pageType isEqualToString:@"message"]) {
            imageInText = false;
            isAnimationOrVideo = true;
        } else if ([webPage.pageType isEqualToString:@"article"]) {
            CGSize imageSize = CGSizeZero;
            [webPage.photo.imageInfo imageUrlForLargestSize:&imageSize];
            if (imageSize.width > 400.0f && webPage.instantPage != nil) {
                imageInText = false;
            }
        }
        
        if ([webPage.document.mimeType isEqualToString:@"image/gif"]) {
            imageInText = false;
        }
        
        bool isMusic = false;
        bool isVoice = false;
        bool isSticker = false;
        bool isRoundVideo = false;
        
        for (id attribute in webPage.document.attributes) {
            if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                if (((TGDocumentAttributeAudio *)attribute).isVoice) {
                    isVoice = true;
                } else {
                    isMusic = true;
                }
            } else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                if (((TGDocumentAttributeVideo *)attribute).isRoundMessage) {
                    isRoundVideo = true;
                }
                else {
                    isAnimationOrVideo = true;
                }
            } else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]]) {
                isSticker = true;
            }
        }
        
        if (isVoice) {
            _webPageFooterModel = [[TGAudioWebpageFooterModel alloc] initWithContext:_context messageId:_mid incoming:_incomingAppearance webPage:webPage hasViews:_messageViews != nil];
            _webPageFooterModel.mediaIsAvailable = _mediaIsAvailable;
            [_webPageFooterModel updateMediaProgressVisible:_mediaProgressVisible mediaProgress:_mediaProgress animated:false];
            _webPageFooterModel.boundToContainer = _boundToContainer;
            [_contentModel addSubmodel:_webPageFooterModel];
        } else if (isMusic) {
            _webPageFooterModel = [[TGMusicWebpageFooterModel alloc] initWithContext:_context messageId:_mid incoming:_incomingAppearance webPage:webPage hasViews:_messageViews != nil];
            _webPageFooterModel.mediaIsAvailable = _mediaIsAvailable;
            [_webPageFooterModel updateMediaProgressVisible:_mediaProgressVisible mediaProgress:_mediaProgress animated:false];
            _webPageFooterModel.boundToContainer = _boundToContainer;
            [_contentModel addSubmodel:_webPageFooterModel];
        } else if (isSticker) {
            _webPageFooterModel = [[TGStickerWebpageFooterModel alloc] initWithContext:_context incoming:_incomingAppearance webPage:webPage hasViews:_messageViews != nil];
            _webPageFooterModel.mediaIsAvailable = _mediaIsAvailable;
            [_webPageFooterModel updateMediaProgressVisible:_mediaProgressVisible mediaProgress:_mediaProgress animated:false];
            _webPageFooterModel.boundToContainer = _boundToContainer;
            [_contentModel addSubmodel:_webPageFooterModel];
        } else if (isRoundVideo) {
            _webPageFooterModel = [[TGRoundVideoWebpageFooterModel alloc] initWithContext:_context messageId:_mid incoming:_incomingAppearance webPage:webPage];
            _webPageFooterModel.mediaIsAvailable = _mediaIsAvailable;
            [_webPageFooterModel updateMediaProgressVisible:_mediaProgressVisible mediaProgress:_mediaProgress animated:false];
            _webPageFooterModel.boundToContainer = _boundToContainer;
            [_contentModel addSubmodel:_webPageFooterModel];
        } else if (webPage.photo == nil && webPage.document != nil && !isAnimationOrVideo) {
            _webPageFooterModel = [[TGDocumentWebpageFooterModel alloc] initWithContext:_context incoming:_incomingAppearance webPage:webPage hasViews:_messageViews != nil];
            _webPageFooterModel.mediaIsAvailable = _mediaIsAvailable;
            [_webPageFooterModel updateMediaProgressVisible:_mediaProgressVisible mediaProgress:_mediaProgress animated:false];
            _webPageFooterModel.boundToContainer = _boundToContainer;
            [_contentModel addSubmodel:_webPageFooterModel];
        } else {
            _webPageFooterModel = [[TGArticleWebpageFooterModel alloc] initWithContext:_context incoming:_incomingAppearance webPage:webPage imageInText:imageInText invoice:invoice];
            _webPageFooterModel.mediaIsAvailable = _mediaIsAvailable;
            [_webPageFooterModel updateMediaProgressVisible:_mediaProgressVisible mediaProgress:_mediaProgress animated:false];
            _webPageFooterModel.boundToContainer = _boundToContainer;
            __weak TGContentBubbleViewModel *weakSelf = self;
            ((TGArticleWebpageFooterModel *)_webPageFooterModel).instantPagePressed = ^{
                __strong TGContentBubbleViewModel *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf instantPageButtonPressed];
                }
            };
            ((TGArticleWebpageFooterModel *)_webPageFooterModel).viewGroupPressed = ^{
                __strong TGContentBubbleViewModel *strongSelf = weakSelf;
                if (strongSelf != nil && webPage.url != nil) {
                    [strongSelf->_context.companionHandle requestAction:@"openLinkRequested" options:@{@"url": webPage.url}];
                }
            };
            [_contentModel addSubmodel:_webPageFooterModel];
        }
    }
    
    if ([_contentModel boundView] != nil)
    {
        [_webPageFooterModel bindSpecialViewsToContainer:_contentModel.boundView viewStorage:viewStorage atItemPosition:CGPointMake(_itemPosition.x + _webPageFooterModel.frame.origin.x, _itemPosition.y + _webPageFooterModel.frame.origin.y)];
    }
    
    _shareButtonModel.hidden = webPage == nil;
    _hasInvoice = invoice != nil;
}

- (void)instantPageButtonPressed {
    
}

- (UIView *)referenceViewForImageTransition
{
    return [_webPageFooterModel referenceViewForImageTransition];
}

- (void)updateMediaVisibility
{
    [_webPageFooterModel setMediaVisible:[_context isMediaVisibleInMessage:_mid]];
}

- (TGModernImageViewModel *)unsentButtonModel
{
    if (_unsentButtonModel == nil)
    {
        static UIImage *image = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            image = [UIImage imageNamed:@"ModernMessageUnsentButton.png"];
        });
        
        _unsentButtonModel = [[TGModernImageViewModel alloc] initWithImage:image];
        _unsentButtonModel.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
        _unsentButtonModel.extendedEdges = UIEdgeInsetsMake(6, 6, 6, 6);
    }
    
    return _unsentButtonModel;
}

- (void)updateMediaAvailability:(bool)mediaIsAvailable viewStorage:(TGModernViewStorage *)__unused viewStorage delayDisplay:(bool)delayDisplay {
    [super updateMediaAvailability:mediaIsAvailable viewStorage:viewStorage delayDisplay:delayDisplay];
    
    _mediaIsAvailable = mediaIsAvailable;
    _webPageFooterModel.mediaIsAvailable = mediaIsAvailable;
}

- (void)updateProgress:(bool)progressVisible progress:(float)progress viewStorage:(TGModernViewStorage *)viewStorage animated:(bool)animated {
    [super updateProgress:progressVisible progress:progress viewStorage:viewStorage animated:animated];
    
    _mediaProgressVisible = progressVisible;
    _mediaProgress = progress;
    
    if (_webPageFooterModel != nil) {
        [_webPageFooterModel updateMediaProgressVisible:progressVisible mediaProgress:progress animated:animated];
    }
}

- (void)updateMessageAttributes {
    [super updateMessageAttributes];
    
    bool previousRead = _read;

    _read = ![_context isMessageUnread:_message];
    
    if (_read != previousRead) {
        if (_read) {
            _checkSecondModel.alpha = 1.0f;
            
            if (!previousRead && [_checkSecondModel boundView] != nil) {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                animation.fromValue = @(1.3f);
                animation.toValue = @(1.0f);
                animation.duration = 0.1;
                animation.removedOnCompletion = true;
                
                [[_checkSecondModel boundView].layer addAnimation:animation forKey:@"transform.scale"];
            }
        }
    }
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated
{
    [super updateMessage:message viewStorage:viewStorage sizeUpdated:sizeUpdated];
    
    bool hadReceipt = false;
    for (TGMediaAttachment *media in _message.mediaAttachments) {
        if (media.type == TGInvoiceMediaAttachmentType) {
            hadReceipt = ((TGInvoiceMediaAttachment *)media).receiptMessageId != 0;
            break;
        }
    }
    
    _message = message;
    _mid = message.mid;
    
    if (_messageViewsModel != nil) {
        _messageViewsModel.count = message.viewCount.viewCount;
        CGFloat previousWidth = _messageViewsModel.frame.size.width;
        [_messageViewsModel sizeToFit];
        if (ABS(previousWidth - _messageViewsModel.frame.size.width) > FLT_EPSILON) {
            if (sizeUpdated) {
                *sizeUpdated = true;
            }
        }
    }
    
    TGWebPageMediaAttachment *webPage = nil;
    TGInvoiceMediaAttachment *invoice = nil;
    for (id attachment in message.mediaAttachments)
    {
        if ([attachment isKindOfClass:[TGWebPageMediaAttachment class]])
        {
            webPage = attachment;
        } else if ([attachment isKindOfClass:[TGGameMediaAttachment class]]) {
            webPage = [((TGGameMediaAttachment *)attachment) webPageWithText:message.text entities:message.entities];
        } else if ([attachment isKindOfClass:[TGInvoiceMediaAttachment class]]) {
            webPage = [((TGInvoiceMediaAttachment *)attachment) webpage];
            invoice = attachment;
        }
    }
    
    if (webPage != nil) {
        if (_webPageFooterModel == nil) {
            if (![_webPage isEqual:webPage])
            {
                if (webPage.title.length != 0 || webPage.pageDescription.length != 0 || webPage.siteName.length != 0 || [webPage.photo.imageInfo imageUrlForLargestSize:NULL] != nil || [webPage.document.thumbnailInfo imageUrlForLargestSize:NULL] != nil) {
                    [self setWebPageFooter:webPage invoice:invoice viewStorage:viewStorage];
                    if (sizeUpdated)
                        *sizeUpdated = true;
                }
            }
        } else if (![_webPage isEqual:webPage])
        {
            [_contentModel removeSubmodel:_webPageFooterModel viewStorage:viewStorage];
            _webPageFooterModel = nil;
            
            [self setWebPageFooter:webPage invoice:invoice viewStorage:viewStorage];
            if (sizeUpdated)
                *sizeUpdated = true;
        }
        else {
            [_webPageFooterModel updateMessageId:_mid];
        }
    }
    
    if (webPage == nil && _webPageFooterModel != nil) {
        [_contentModel removeSubmodel:_webPageFooterModel viewStorage:viewStorage];
        _webPageFooterModel = nil;
        
        [self setWebPageFooter:nil invoice:invoice viewStorage:viewStorage];
        if (sizeUpdated)
            *sizeUpdated = true;
    }
    
    bool messageUnread = [_context isMessageUnread:message];
    
    if (_deliveryState != message.deliveryState || (!_incoming && _read != !messageUnread))
    {
        TGMessageViewModelLayoutConstants const *layoutConstants = TGGetMessageViewModelLayoutConstants();
        
        TGMessageDeliveryState previousDeliveryState = _deliveryState;
        _deliveryState = message.deliveryState;
        
        if (_messageViewsModel != nil) {
            _messageViewsModel.hidden = _deliveryState != TGMessageDeliveryStateDelivered;
        }
        
        bool previousRead = _read;
        _read = !messageUnread;
        
        if (_date != (int32_t)message.date && !debugShowMessageIds)
        {
            _date = (int32_t)message.date;
            
            int daytimeVariant = 0;
            NSString *dateText = [TGDateUtils stringForShortTime:(int)message.date daytimeVariant:&daytimeVariant];
            [_dateModel setText:dateText daytimeVariant:daytimeVariant];
        }
        
        if (_deliveryState == TGMessageDeliveryStateDelivered)
        {
            if (_progressModel != nil)
            {
                [self removeSubmodel:_progressModel viewStorage:viewStorage];
                _progressModel = nil;
            }
            
            _checkFirstModel.alpha = 1.0f;
            
            if (previousDeliveryState == TGMessageDeliveryStatePending && [_checkFirstModel boundView] != nil)
            {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                animation.fromValue = @(1.3f);
                animation.toValue = @(1.0f);
                animation.duration = 0.1;
                animation.removedOnCompletion = true;
                
                [[_checkFirstModel boundView].layer addAnimation:animation forKey:@"transform.scale"];
            }
            
            if (_read)
            {
                _checkSecondModel.alpha = 1.0f;
                
                if (!previousRead && [_checkSecondModel boundView] != nil)
                {
                    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                    animation.fromValue = @(1.3f);
                    animation.toValue = @(1.0f);
                    animation.duration = 0.1;
                    animation.removedOnCompletion = true;
                    
                    [[_checkSecondModel boundView].layer addAnimation:animation forKey:@"transform.scale"];
                }
            }
            
            if (_unsentButtonModel != nil)
            {
                [self removeSubmodel:_unsentButtonModel viewStorage:viewStorage];
                _unsentButtonModel = nil;
            }
        }
        else if (_deliveryState == TGMessageDeliveryStateFailed)
        {
            if (_progressModel != nil)
            {
                [self removeSubmodel:_progressModel viewStorage:viewStorage];
                _progressModel = nil;
            }
            
            if (_checkFirstModel != nil)
            {
                if (_checkFirstEmbeddedInContent)
                {
                    [_contentModel removeSubmodel:_checkFirstModel viewStorage:viewStorage];
                    [_contentModel setNeedsSubmodelContentsUpdate];
                }
                else
                    [self removeSubmodel:_checkFirstModel viewStorage:viewStorage];
            }
            
            if (_checkSecondModel != nil)
            {
                if (_checkSecondEmbeddedInContent)
                {
                    [_contentModel removeSubmodel:_checkSecondModel viewStorage:viewStorage];
                    [_contentModel setNeedsSubmodelContentsUpdate];
                }
                else
                    [self removeSubmodel:_checkSecondModel viewStorage:viewStorage];
            }
            
            if (_unsentButtonModel == nil)
            {
                [self addSubmodel:[self unsentButtonModel]];
                if ([_contentModel boundView] != nil)
                    [_unsentButtonModel bindViewToContainer:[_contentModel boundView].superview viewStorage:viewStorage];
                _unsentButtonModel.frame = CGRectOffset(_unsentButtonModel.frame, self.frame.size.width + _unsentButtonModel.frame.size.width, self.frame.size.height - _unsentButtonModel.frame.size.height - ((_collapseFlags & TGModernConversationItemCollapseBottom) ? 5 : 6));
                
                _unsentButtonTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unsentButtonTapGesture:)];
                [[_unsentButtonModel boundView] addGestureRecognizer:_unsentButtonTapRecognizer];
            }
            
            if (self.frame.size.width > FLT_EPSILON)
            {
                if ([_contentModel boundView] != nil)
                {
                    [UIView animateWithDuration:0.2 animations:^
                     {
                         [self layoutForContainerSize:CGSizeMake(self.frame.size.width, 0.0f)];
                     }];
                }
                else
                    [self layoutForContainerSize:CGSizeMake(self.frame.size.width, 0.0f)];
            }
            
            [_contentModel updateSubmodelContentsIfNeeded];
        }
        else if (_deliveryState == TGMessageDeliveryStatePending)
        {
            if (_progressModel == nil)
            {
                CGFloat unsentOffset = 0.0f;
                if (!_incomingAppearance && previousDeliveryState == TGMessageDeliveryStateFailed)
                    unsentOffset = 29.0f;
                
                bool hasSignature = false;
                if (_authorSignature.length != 0) {
                    hasSignature = true;
                }
                CGFloat signatureSize = (hasSignature ? (_authorSignatureModel.frame.size.width + 8.0f) : 0.0f);
                
                _progressModel = [[TGModernClockProgressViewModel alloc] initWithType:_incomingAppearance ? TGModernClockProgressTypeIncomingClock : TGModernClockProgressTypeOutgoingClock];
                if (_incomingAppearance) {
                    _progressModel.frame = CGRectMake(CGRectGetMaxX(_backgroundModel.frame) - _dateModel.frame.size.width - 27.0f - layoutConstants->rightInset - unsentOffset + (TGIsPad() ? 12.0f : 0.0f) - signatureSize, _contentModel.frame.origin.y + _contentModel.frame.size.height - 17 + 1.0f, 15, 15);
                } else {
                    _progressModel.frame = CGRectMake(CGRectGetMaxX(_backgroundModel.frame) - 23.0f - layoutConstants->rightInset - unsentOffset + (TGIsPad() ? 12.0f : 0.0f) - signatureSize, _contentModel.frame.origin.y + _contentModel.frame.size.height - 17 + 1.0f, 15, 15);
                }
                [self addSubmodel:_progressModel];
                
                if ([_contentModel boundView] != nil)
                {
                    [_progressModel bindViewToContainer:[_contentModel boundView].superview viewStorage:viewStorage];
                }
            }
            
            [_contentModel removeSubmodel:_checkFirstModel viewStorage:viewStorage];
            [_contentModel removeSubmodel:_checkSecondModel viewStorage:viewStorage];
            _checkFirstEmbeddedInContent = false;
            _checkSecondEmbeddedInContent = false;
            
            if (!_incomingAppearance && !_inhibitChecks) {
                if (![self containsSubmodel:_checkFirstModel])
                {
                    [self addSubmodel:_checkFirstModel];
                    
                    if ([_contentModel boundView] != nil)
                        [_checkFirstModel bindViewToContainer:[_contentModel boundView].superview viewStorage:viewStorage];
                }
                if (![self containsSubmodel:_checkSecondModel])
                {
                    [self addSubmodel:_checkSecondModel];
                    
                    if ([_contentModel boundView] != nil)
                        [_checkSecondModel bindViewToContainer:[_contentModel boundView].superview viewStorage:viewStorage];
                }
            }
            
            _checkFirstModel.alpha = 0.0f;
            _checkSecondModel.alpha = 0.0f;
            
            if (_unsentButtonModel != nil)
            {
                UIView<TGModernView> *unsentView = [_unsentButtonModel boundView];
                if (unsentView != nil)
                {
                    [unsentView removeGestureRecognizer:_unsentButtonTapRecognizer];
                    _unsentButtonTapRecognizer = nil;
                }
                
                if (unsentView != nil)
                {
                    [viewStorage allowResurrectionForOperations:^
                     {
                         [self removeSubmodel:_unsentButtonModel viewStorage:viewStorage];
                         
                         UIView *restoredView = [viewStorage dequeueViewWithIdentifier:[unsentView viewIdentifier] viewStateIdentifier:[unsentView viewStateIdentifier]];
                         
                         if (restoredView != nil)
                         {
                             [[_contentModel boundView].superview addSubview:restoredView];
                             
                             [UIView animateWithDuration:0.2 animations:^
                              {
                                  restoredView.frame = CGRectOffset(restoredView.frame, restoredView.frame.size.width + 9, 0.0f);
                                  restoredView.alpha = 0.0f;
                              } completion:^(__unused BOOL finished)
                              {
                                  [viewStorage enqueueView:restoredView];
                              }];
                         }
                     }];
                }
                else
                    [self removeSubmodel:_unsentButtonModel viewStorage:viewStorage];
                
                _unsentButtonModel = nil;
            }
            
            if (self.frame.size.width > FLT_EPSILON)
            {
                if ([_contentModel boundView] != nil)
                {
                    [UIView animateWithDuration:0.2 animations:^
                     {
                         [self layoutForContainerSize:CGSizeMake(self.frame.size.width, 0.0f)];
                     }];
                }
                else
                    [self layoutForContainerSize:CGSizeMake(self.frame.size.width, 0.0f)];
            }
            
            [_contentModel setNeedsSubmodelContentsUpdate];
            [_contentModel updateSubmodelContentsIfNeeded];
        }
    }
    
    TGBotReplyMarkup *replyMarkup = message.replyMarkup != nil && message.replyMarkup.isInline ? message.replyMarkup : nil;
    if (!TGObjectCompare(_replyMarkup, replyMarkup) || hadReceipt != (invoice.receiptMessageId != 0)) {
        _replyMarkup = replyMarkup;
        
        if (_replyButtonsModel == nil) {
            _replyButtonsModel = [[TGMessageReplyButtonsModel alloc] init];
            __weak TGContentBubbleViewModel *weakSelf = self;
            _replyButtonsModel.buttonActivated = ^(TGBotReplyMarkupButton *button, NSInteger index) {
                __strong TGContentBubbleViewModel *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{@"mid": @(strongSelf->_mid), @"command": button.text}];
                    if (button.action != nil) {
                        dict[@"action"] = button.action;
                    }
                    dict[@"index"] = @(index);
                    [strongSelf->_context.companionHandle requestAction:@"activateCommand" options:dict];
                }
            };
            
            [self addSubmodel:_replyButtonsModel];
        }
        
        bool hasReceipt = false;
        if (invoice != nil) {
            hasReceipt = invoice.receiptMessageId != 0;
        }
        
        if (_backgroundModel.boundView != nil) {
            [_replyButtonsModel unbindView:viewStorage];
            [_replyButtonsModel setReplyMarkup:replyMarkup hasReceipt:hasReceipt];
            [_replyButtonsModel bindViewToContainer:_backgroundModel.boundView.superview viewStorage:viewStorage];
        } else {
            [_replyButtonsModel setReplyMarkup:replyMarkup hasReceipt:hasReceipt];
        }
        if (sizeUpdated) {
            *sizeUpdated = true;
        }
    }
    
    if (message.isEdited && !(_context.isBot || ([_authorPeer isKindOfClass:[TGUser class]] && ((TGUser *)_authorPeer).kind != TGUserKindGeneric)) && (_authorPeer == nil || ![_authorPeer isKindOfClass:[TGConversation class]] || !((TGConversation *)_authorPeer).isChannel || ((TGConversation *)_authorPeer).isChannelGroup)) {
        if (_editedLabelModel == nil) {
            static CTFontRef dateFont = NULL;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                if (iosMajorVersion() >= 7) {
                    dateFont = CTFontCreateWithFontDescriptor((__bridge CTFontDescriptorRef)[TGItalicSystemFontOfSize(11.0f) fontDescriptor], 0.0f, NULL);
                } else {
                    UIFont *font = TGItalicSystemFontOfSize(11.0f);
                    dateFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, nil);
                }
            });
            _editedLabelModel = [[TGModernLabelViewModel alloc] initWithText:TGLocalized(@"Conversation.MessageEditedLabel") textColor:_dateModel.textColor font:dateFont maxWidth:CGFLOAT_MAX];
            [_contentModel addSubmodel:_editedLabelModel];
            
            if (sizeUpdated) {
                *sizeUpdated = true;
            }
        }
    }
}

- (void)updateEditingState:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage animationDelay:(NSTimeInterval)animationDelay
{
    bool editing = _context.editing;
    if (editing != _editing)
    {
        [super updateEditingState:container viewStorage:viewStorage animationDelay:animationDelay];
        
        _backgroundModel.viewUserInteractionDisabled = _editing;
    }
}

- (void)_maybeRestructureStateModels:(TGModernViewStorage *)viewStorage
{
    if (!_incoming && !_inhibitChecks && [_contentModel boundView] == nil && !_incomingAppearance)
    {
        if (_deliveryState == TGMessageDeliveryStateDelivered)
        {
            if (!_checkFirstEmbeddedInContent)
            {
                if ([self.submodels containsObject:_checkFirstModel])
                {
                    _checkFirstEmbeddedInContent = true;
                    
                    [self removeSubmodel:_checkFirstModel viewStorage:viewStorage];
                    _checkFirstModel.frame = CGRectOffset(_checkFirstModel.frame, -_contentModel.frame.origin.x, -_contentModel.frame.origin.y);
                    [_contentModel addSubmodel:_checkFirstModel];
                }
            }
            
            if (_read && !_checkSecondEmbeddedInContent)
            {
                if ([self.submodels containsObject:_checkSecondModel])
                {
                    _checkSecondEmbeddedInContent = true;
                    
                    [self removeSubmodel:_checkSecondModel viewStorage:viewStorage];
                    _checkSecondModel.frame = CGRectOffset(_checkSecondModel.frame, -_contentModel.frame.origin.x, -_contentModel.frame.origin.y);
                    [_contentModel addSubmodel:_checkSecondModel];
                }
            }
        }
    }
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
    
    _itemPosition = itemPosition;
    
    [_backgroundModel bindViewToContainer:container viewStorage:viewStorage];
    [_backgroundModel boundView].frame = CGRectOffset([_backgroundModel boundView].frame, itemPosition.x, itemPosition.y);
    
    [_replyHeaderModel bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:CGPointMake(itemPosition.x + _contentModel.frame.origin.x + _replyHeaderModel.frame.origin.x, itemPosition.y + _contentModel.frame.origin.y + _replyHeaderModel.frame.origin.y)];
    
    [_webPageFooterModel bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:CGPointMake(itemPosition.x + _contentModel.frame.origin.x + _webPageFooterModel.frame.origin.x, itemPosition.y + _contentModel.frame.origin.y + _webPageFooterModel.frame.origin.y)];
    
    [_replyButtonsModel bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:CGPointMake(itemPosition.x, itemPosition.y)];
    
    [self subscribeToCallbackButtonInProgress];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [self _maybeRestructureStateModels:viewStorage];
    
    _boundToContainer = true;
    _itemPosition = CGPointZero;
    
    [self updateEditingState:nil viewStorage:nil animationDelay:-1.0];
    
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    [_replyHeaderModel bindSpecialViewsToContainer:_contentModel.boundView viewStorage:viewStorage atItemPosition:CGPointMake(_replyHeaderModel.frame.origin.x, _replyHeaderModel.frame.origin.y)];
    
    _webPageFooterModel.boundToContainer = true;
    [_webPageFooterModel bindSpecialViewsToContainer:_contentModel.boundView viewStorage:viewStorage atItemPosition:CGPointMake(_webPageFooterModel.frame.origin.x, _webPageFooterModel.frame.origin.y)];
    
    _boundDoubleTapRecognizer = [[TGDoubleTapGestureRecognizer alloc] initWithTarget:self action:@selector(messageDoubleTapGesture:)];
    _boundDoubleTapRecognizer.cancelsTouchesInView = true;
    _boundDoubleTapRecognizer.delegate = self;
    _boundDoubleTapRecognizer.avoidControls = true;
    
    UIView *backgroundView = [_backgroundModel boundView];
    [backgroundView addGestureRecognizer:_boundDoubleTapRecognizer];
    
    if (_unsentButtonModel != nil)
    {
        _unsentButtonTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unsentButtonTapGesture:)];
        [[_unsentButtonModel boundView] addGestureRecognizer:_unsentButtonTapRecognizer];
    }
    
    if (_shareButtonModel != nil) {
        [(TGModernButtonView *)_shareButtonModel.boundView addTarget:self action:@selector(sharePressed) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self subscribeToCallbackButtonInProgress];
}

- (void)subscribeToCallbackButtonInProgress {
    if (_replyButtonsModel != nil) {
        __weak TGContentBubbleViewModel *weakSelf = self;
        [_callbackButtonInProgressDisposable setDisposable:[[[_context callbackInProgress] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *next) {
            __strong TGContentBubbleViewModel *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (next != nil) {
                    if ([next[@"mid"] intValue] == strongSelf->_mid) {
                        [strongSelf->_replyButtonsModel setButtonIndexInProgress:[next[@"buttonIndex"] intValue]];
                    } else {
                        [strongSelf->_replyButtonsModel setButtonIndexInProgress:NSNotFound];
                    }
                } else {
                    [strongSelf->_replyButtonsModel setButtonIndexInProgress:NSNotFound];
                }
            }
        }]];
    }
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    UIView *backgroundView = [_backgroundModel boundView];
    [backgroundView removeGestureRecognizer:_boundDoubleTapRecognizer];
    _boundDoubleTapRecognizer.delegate = nil;
    _boundDoubleTapRecognizer = nil;
    
    if (_unsentButtonModel != nil)
    {
        [[_unsentButtonModel boundView] removeGestureRecognizer:_unsentButtonTapRecognizer];
        _unsentButtonTapRecognizer = nil;
    }
    
    if (_shareButtonModel != nil)
    {
        [(TGModernButtonView *)_shareButtonModel.boundView removeTarget:self action:@selector(sharePressed) forControlEvents:UIControlEventTouchUpInside];
    }
    
    _boundToContainer = false;
    _webPageFooterModel.boundToContainer = false;
    
    [super unbindView:viewStorage];
    
    [_callbackButtonInProgressDisposable setDisposable:nil];
}

- (void)relativeBoundsUpdated:(CGRect)bounds
{
    [super relativeBoundsUpdated:bounds];
    
    [_contentModel updateSubmodelContentsForVisibleRect:CGRectOffset(bounds, -_contentModel.frame.origin.x, -_contentModel.frame.origin.y)];
}

- (CGRect)effectiveContentFrame
{
    return _backgroundModel.frame;
}

- (void)messageDoubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan)
    {
        if (recognizer.state == UIGestureRecognizerStateRecognized)
        {
            CGPoint point = [recognizer locationInView:[_contentModel boundView]];
            
            if (recognizer.longTapped)
                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
            else if (recognizer.doubleTapped)
                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
            else if (_forwardedHeaderModel && CGRectContainsPoint(_forwardedHeaderModel.frame, point)) {
                if (TGPeerIdIsChannel(_forwardedPeerId)) {
                    [_context.companionHandle requestAction:@"peerAvatarTapped" options:@{@"peerId": @(_forwardedPeerId), @"messageId": @(_forwardedMessageId)}];
                } else {
                    [_context.companionHandle requestAction:@"userAvatarTapped" options:@{@"uid": @((int32_t)_forwardedPeerId)}];
                }
            }
            else if (_replyHeaderModel && CGRectContainsPoint(_replyHeaderModel.frame, point))
                [_context.companionHandle requestAction:@"navigateToMessage" options:@{@"mid": @(_replyMessageId), @"sourceMid": @(_mid)}];
        }
    }
}

- (void)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer didBeginAtPoint:(CGPoint)__unused point
{
}

- (void)gestureRecognizerDidFail:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
}

- (void)unsentButtonTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [_context.companionHandle requestAction:@"showUnsentMessageMenu" options:@{@"mid": @(_mid)}];
    }
}

- (bool)gestureRecognizerShouldHandleLongTap:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
    return true;
}

- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer shouldFailTap:(CGPoint)__unused point
{
    return 0;
}

- (void)doubleTapGestureRecognizerSingleTapped:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
}

- (void)setCollapseFlags:(int)collapseFlags
{
    if (_collapseFlags != collapseFlags)
    {
        _collapseFlags = collapseFlags;
        if ([_authorPeer isKindOfClass:[TGConversation class]]) {
            [_backgroundModel setPartialMode:false];
        } else {
            [_backgroundModel setPartialMode:collapseFlags & TGModernConversationItemCollapseBottom];
        }
    }
}

- (void)layoutContentForHeaderHeight:(CGFloat)headerHeight
{
}

- (void)layoutContentForHeaderHeight:(CGFloat)headerHeight containerSize:(CGSize)containerSize {
    [self layoutContentForHeaderHeight:headerHeight];
}

- (CGSize)contentSizeForContainerSize:(CGSize)__unused containerSize needsContentsUpdate:(bool *)__unused needsContentsUpdate infoWidth:(CGFloat)__unused infoWidth
{
    return CGSizeZero;
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    bool isPost = _authorPeer != nil && [_authorPeer isKindOfClass:[TGConversation class]];
    
    TGMessageViewModelLayoutConstants const *layoutConstants = TGGetMessageViewModelLayoutConstants();
    
    bool isRTL = TGIsRTL();
    
    CGFloat topSpacing = (_collapseFlags & TGModernConversationItemCollapseTop) ? layoutConstants->topInsetCollapsed : layoutConstants->topInset;
    CGFloat bottomSpacing = (_collapseFlags & TGModernConversationItemCollapseBottom) ? layoutConstants->bottomInsetCollapsed : layoutConstants->bottomInset;
    
    if (isPost) {
        topSpacing = layoutConstants->topPostInset;
        bottomSpacing = layoutConstants->bottomPostInset;
    }
    
    CGSize contentContainerSize = CGSizeMake(MIN(420.0f, containerSize.width - 80.0f - (_hasAvatar ? 38.0f : 0.0f)), containerSize.height);
    if (_shareButtonModel != nil && !_shareButtonModel.hidden) {
        contentContainerSize.width -= 20.0f;
    }
    
    bool updateContents = false;
    
    bool hasSignature = false;
    if (_authorSignature.length != 0) {
        hasSignature = true;
        if ([_authorSignatureModel layoutNeedsUpdatingForContainerSize:CGSizeMake(contentContainerSize.width - 80.0f - _editedLabelModel.frame.size.width, CGFLOAT_MAX)]) {
            updateContents = true;
            [_authorSignatureModel layoutForContainerSize:CGSizeMake(contentContainerSize.width - 80.0f, CGFLOAT_MAX)];
        }
    } else {
        _authorSignatureModel.frame = CGRectZero;
    }
    
    CGFloat infoWidth = 0.0f;
    if (!_incoming) {
        if (_messageViews == nil) {
            infoWidth += 12.0f;
        } else {
            infoWidth += MAX(0.0f, 12.0f - _messageViewsModel.frame.size.width);
            if (!isPost) {
                infoWidth += 12.0f;
            }
        }
    }
    infoWidth += _dateModel.frame.size.width + 10.0f;
    if (_editedLabelModel != nil) {
        infoWidth += _editedLabelModel.frame.size.width + 4.0f;
    }
    
    if (hasSignature) {
        infoWidth += _authorSignatureModel.frame.size.width + 6.0f;
    }
    
    if (_messageViews != nil) {
        infoWidth += _messageViewsModel.frame.size.width + 6.0f;
    }
    
    CGFloat maxHeaderWidth = contentContainerSize.width;
    bool alreadyMeasuredWebPage = false;
    bool webpageOnly = false;
    bool alreadyMeasuredWebpageHasBottomInset = false;
    if ([_webPageFooterModel fitContentToWebpage])
    {
        alreadyMeasuredWebPage = true;
        [_webPageFooterModel layoutForContainerSize:CGSizeMake(contentContainerSize.width, contentContainerSize.height) contentSize:CGSizeZero infoWidth:infoWidth needsContentUpdate:&updateContents bottomInset:&alreadyMeasuredWebpageHasBottomInset];
        maxHeaderWidth = _webPageFooterModel.frame.size.width;
    }
    webpageOnly = alreadyMeasuredWebPage || _hasInvoice;
    
    CGSize headerSize = CGSizeZero;
    if (_authorNameModel != nil)
    {
        CGFloat maxWidth = maxHeaderWidth;
        CGFloat maxNameWidth = _viaUserModel == nil ? maxWidth : maxWidth - 46.0f;
        
        if (_authorNameModel.frame.size.width < FLT_EPSILON)
            [_authorNameModel layoutForContainerSize:CGSizeMake(maxNameWidth, 0.0f)];
        
        CGRect authorNameFrame = _authorNameModel.frame;
        authorNameFrame.origin = CGPointMake(1.0f, 1.0f + TGRetinaPixel);
        _authorNameModel.frame = authorNameFrame;
        
        headerSize = CGSizeMake(_authorNameModel.frame.size.width, _authorNameModel.frame.size.height + 1.0f);
        
        if (_viaUserModel != nil) {
            [_viaUserModel layoutForContainerSize:CGSizeMake(maxWidth - _authorNameModel.frame.size.width, 0.0f)];
            CGRect viaUserFrame = _viaUserModel.frame;
            viaUserFrame.origin = CGPointMake(CGRectGetMaxX(_authorNameModel.frame) + 4.0f, 1.0f + TGRetinaPixel);
            _viaUserModel.frame = viaUserFrame;
            
            headerSize.width += viaUserFrame.size.width + 4.0f;
        }
    } else if (_viaUserModel != nil) {
        [_viaUserModel layoutForContainerSize:CGSizeMake(320.0f - 80.0f - (_hasAvatar ? 38.0f : 0.0f), 0.0f)];
        
        CGRect viaUserFrame = _viaUserModel.frame;
        viaUserFrame.origin = CGPointMake(1.0f, 1.0f + TGRetinaPixel);
        _viaUserModel.frame = viaUserFrame;
        
        headerSize = CGSizeMake(_viaUserModel.frame.size.width, _viaUserModel.frame.size.height + 1.0f);
    }
    
    if (_forwardedHeaderModel != nil)
    {
        [_forwardedHeaderModel layoutForContainerSize:CGSizeMake(containerSize.width - 80.0f - (_hasAvatar ? 38.0f : 0.0f), containerSize.height)];
        CGRect forwardedHeaderFrame = _forwardedHeaderModel.frame;
        forwardedHeaderFrame.origin = CGPointMake(1.0f, headerSize.height + 1.0f);
        _forwardedHeaderModel.frame = forwardedHeaderFrame;
        
        headerSize.height += forwardedHeaderFrame.size.height;
        headerSize.width = MAX(headerSize.width, forwardedHeaderFrame.size.width);
    }
    
    if (_replyHeaderModel != nil)
    {
        bool updateContent = false;
        [_replyHeaderModel layoutForContainerSize:CGSizeMake(containerSize.width - 80.0f - (_hasAvatar ? 38.0f : 0.0f), containerSize.height) updateContent:&updateContent];
        if (updateContent)
            updateContents = true;
        CGRect replyHeaderFrame = _replyHeaderModel.frame;
        replyHeaderFrame.origin = CGPointMake(1.0f, headerSize.height + 1.0f);
        _replyHeaderModel.frame = replyHeaderFrame;
        
        headerSize.height += replyHeaderFrame.size.height - 1.0f;
        headerSize.width = MAX(headerSize.width, replyHeaderFrame.size.width);
    }
    
    CGFloat contentContainerWidth = contentContainerSize.width;
    CGSize contentSize = CGSizeZero;
    
    headerSize.width = MAX(headerSize.width, infoWidth - 10.0f);
    
    CGSize webPageSize = CGSizeZero;
    if (_webPageFooterModel != nil)
    {
        bool webpageHasBottomInset = false;
        if ([_webPageFooterModel preferWebpageSize])
        {
            if (alreadyMeasuredWebPage) {
                webpageHasBottomInset = alreadyMeasuredWebpageHasBottomInset;
            } else {
                [_webPageFooterModel layoutForContainerSize:CGSizeMake(contentContainerWidth, contentContainerSize.height) contentSize:CGSizeZero infoWidth:infoWidth needsContentUpdate:&updateContents bottomInset:&webpageHasBottomInset];
            }
            
            CGSize fittedContentSize = [self contentSizeForContainerSize:CGSizeMake(_webPageFooterModel.frame.size.width, contentContainerSize.height) needsContentsUpdate:&updateContents infoWidth:0.0f];
            contentContainerWidth = _webPageFooterModel.frame.size.width;
            contentSize = fittedContentSize;
        }
        else
        {
            contentSize = [self contentSizeForContainerSize:CGSizeMake(contentContainerWidth, contentContainerSize.height) needsContentsUpdate:&updateContents infoWidth:0.0f];
            
            [_webPageFooterModel layoutForContainerSize:CGSizeMake(contentContainerWidth, contentContainerSize.height) contentSize:contentSize infoWidth:infoWidth needsContentUpdate:&updateContents bottomInset:&webpageHasBottomInset];
        }
        
        webPageSize = _webPageFooterModel.frame.size;
        if ([_webPageFooterModel preferWebpageSize])
            contentContainerWidth = webPageSize.width;
        
        headerSize.width = MAX(headerSize.width, webPageSize.width);
        
        if (hasSignature && !webpageHasBottomInset) {
            webPageSize.height += 14.0f;
        }
    }
    else
    {
        contentSize = [self contentSizeForContainerSize:CGSizeMake(contentContainerWidth, contentContainerSize.height) needsContentsUpdate:&updateContents infoWidth:infoWidth];
    }
    
    CGFloat replyButtonsMinimumWidth = 0.0f;
    if (_replyButtonsModel != nil) {
        replyButtonsMinimumWidth = [_replyButtonsModel minimumWidth];
        contentSize.width = MAX(contentSize.width, MIN(contentContainerWidth + 14.0f, replyButtonsMinimumWidth));
    }
    
    CGFloat avatarOffset = 0.0f;
    if (_hasAvatar)
        avatarOffset = 38.0f;
    
    CGFloat unsentOffset = 0.0f;
    if (!_incomingAppearance && _deliveryState == TGMessageDeliveryStateFailed)
        unsentOffset = 29.0f;
    
    CGFloat backgroundWidth = MAX(60.0f, MAX(headerSize.width, contentSize.width) + 25.0f);
    CGRect backgroundFrame = CGRectMake(_incomingAppearance ? (avatarOffset + layoutConstants->leftInset) : (containerSize.width - backgroundWidth - layoutConstants->rightInset - unsentOffset), topSpacing, backgroundWidth, MAX(((_hasAvatar && webPageSize.height <= FLT_EPSILON) ? 44.0f : (webpageOnly ? 0.0 : 30.0f)), headerSize.height + contentSize.height + layoutConstants->textBubblePaddingTop + layoutConstants->textBubblePaddingBottom));
    if (_incomingAppearance && _editing)
        backgroundFrame.origin.x += 42.0f;
    
    if (!_editing && fabs(_replyPanOffset) > FLT_EPSILON)
        backgroundFrame.origin.x += _replyPanOffset;
    
    if (contentSize.height <= FLT_EPSILON && _webPageFooterModel == nil) {
        backgroundFrame.size.height -= 10.0f;
    }
    
    if (_webPageFooterModel != nil)
    {
        backgroundFrame.size.height += webPageSize.height;
    }
    
    CGSize previousContentModelSize = _contentModel.frame.size;
    _contentModel.frame = CGRectMake(backgroundFrame.origin.x + (_incomingAppearance ? 14 : 8), topSpacing + 2.0f, MAX(32.0f, MAX(headerSize.width, contentSize.width) + 2 + (_incomingAppearance ? 0.0f : 5.0f)), MAX(headerSize.height + contentSize.height + 5, (_hasAvatar && webPageSize.height <= FLT_EPSILON) ? 30.0f : (webpageOnly ? 0.0 : 14.0f)) + webPageSize.height);
    if (!CGSizeEqualToSize(_contentModel.frame.size, previousContentModelSize)) {
        updateContents = true;
    }
    
    _backgroundModel.frame = backgroundFrame;
    
    if (_shareButtonModel != nil) {
        _shareButtonModel.frame = CGRectOffset(_shareButtonModel.bounds, CGRectGetMaxX(backgroundFrame) + 7.0f, CGRectGetMaxY(backgroundFrame) - 29.0f - 1.0f);
    }
    
    if (_webPageFooterModel != nil)
    {
        [_webPageFooterModel updateSpecialViewsPositions:CGPointMake(_itemPosition.x + _webPageFooterModel.frame.origin.x, _itemPosition.y + headerSize.height + contentSize.height)];
        
        [_webPageFooterModel layoutForContainerSize:contentContainerSize contentSize:contentSize infoWidth:infoWidth needsContentUpdate:&updateContents bottomInset:NULL];
        
        _webPageFooterModel.frame = CGRectMake(0.0f, headerSize.height + contentSize.height, _webPageFooterModel.frame.size.width, _webPageFooterModel.frame.size.height);
    }
    
    if (_authorNameModel != nil)
    {
        CGRect authorModelFrame = _authorNameModel.frame;
        authorModelFrame.origin.x = isRTL ? (_contentModel.frame.size.width - authorModelFrame.size.width - 1.0f) : 1.0f;
        _authorNameModel.frame = authorModelFrame;
        
        CGRect viaUserFrame = _viaUserModel.frame;
        viaUserFrame.origin.x = isRTL ? authorModelFrame.origin.x - viaUserFrame.size.width - 4.0f : (CGRectGetMaxX(authorModelFrame) + 4.0f);
        _viaUserModel.frame = viaUserFrame;
    } else if (_viaUserModel != nil) {
        CGRect viaUserFrame = _viaUserModel.frame;
        viaUserFrame.origin.x = isRTL ? (_contentModel.frame.size.width - viaUserFrame.size.width - 1.0f) : 1.0f;
        _viaUserModel.frame = viaUserFrame;
    }
    
    if (_forwardedHeaderModel != nil)
    {
        CGRect forwardedHeaderFrame = _forwardedHeaderModel.frame;
        forwardedHeaderFrame.origin.x = isRTL ? (_contentModel.frame.size.width - forwardedHeaderFrame.size.width - 1.0f) : 1.0f;
        _forwardedHeaderModel.frame = forwardedHeaderFrame;
    }
    
    if (_replyHeaderModel != nil)
    {
        CGRect replyHeaderFrame = _replyHeaderModel.frame;
        replyHeaderFrame.origin.x = isRTL ? (_contentModel.frame.size.width - replyHeaderFrame.size.width - 1.0f) : 1.0f;
        _replyHeaderModel.frame = replyHeaderFrame;
    }
    
    [self layoutContentForHeaderHeight:headerSize.height containerSize:_contentModel.frame.size];
    
    _dateModel.frame = CGRectMake(_contentModel.frame.size.width - (_incomingAppearance ? (3 + TGRetinaPixel) : 20.0f) - _dateModel.frame.size.width, _contentModel.frame.size.height - 18.0f - (TGIsLocaleArabic() ? 1.0f : 0.0f), _dateModel.frame.size.width, _dateModel.frame.size.height);
    
    _editedLabelModel.frame = CGRectMake(_dateModel.frame.origin.x - _editedLabelModel.frame.size.width - 4.0f, _dateModel.frame.origin.y, _editedLabelModel.frame.size.width, _editedLabelModel.frame.size.height);
    
    if (_broadcastIconModel != nil)
    {
        _broadcastIconModel.frame = (CGRect){{_dateModel.frame.origin.x - 5.0f - _broadcastIconModel.frame.size.width, _dateModel.frame.origin.y + 3.0f + TGRetinaPixel}, _broadcastIconModel.frame.size};
    }
    
    CGFloat signatureSize = (hasSignature ? (_authorSignatureModel.frame.size.width + 8.0f) : 0.0f);
    
    if (_progressModel != nil) {
        if (_incomingAppearance) {
            _progressModel.frame = CGRectMake(CGRectGetMaxX(_backgroundModel.frame) - _dateModel.frame.size.width - 27.0f - layoutConstants->rightInset - unsentOffset + (TGIsPad() ? 12.0f : 0.0f) - signatureSize, _contentModel.frame.origin.y + _contentModel.frame.size.height - 17 + 1.0f, 15, 15);
        } else {
            _progressModel.frame = CGRectMake(CGRectGetMaxX(_backgroundModel.frame) - 23.0f - layoutConstants->rightInset - unsentOffset + (TGIsPad() ? 12.0f : 0.0f) - signatureSize, _contentModel.frame.origin.y + _contentModel.frame.size.height - 17 + 1.0f, 15, 15);
        }
    }
    
    if (_authorSignature.length != 0) {
        CGFloat minX = _dateModel.frame.origin.x;
        if (_editedLabelModel != nil) {
            minX = _editedLabelModel.frame.origin.x;
        }
        _authorSignatureModel.frame = CGRectMake(minX - _authorSignatureModel.frame.size.width - 6.0f, _dateModel.frame.origin.y - 1.0f, _authorSignatureModel.frame.size.width, _authorSignatureModel.frame.size.height);
    } else {
        _authorSignatureModel.frame = CGRectZero;
    }
    
    if (_messageViewsModel != nil) {
        CGFloat minX = _dateModel.frame.origin.x;
        if (_editedLabelModel != nil) {
            minX = _editedLabelModel.frame.origin.x;
        }
        if (_authorSignature.length != 0) {
            minX = _authorSignatureModel.frame.origin.x;
        }
        _messageViewsModel.frame = CGRectMake(minX - _messageViewsModel.frame.size.width - 6.0f + _contentModel.frame.origin.x, _dateModel.frame.origin.y + _contentModel.frame.origin.y + 2.0f + TGRetinaPixel, _messageViewsModel.frame.size.width, _messageViewsModel.frame.size.height);
    }
    
    CGPoint stateOffset = _contentModel.frame.origin;
    if (_checkFirstModel != nil)
        _checkFirstModel.frame = CGRectMake((_checkFirstEmbeddedInContent ? 0.0f : stateOffset.x) + _contentModel.frame.size.width - 17, (_checkFirstEmbeddedInContent ? 0.0f : stateOffset.y) + _contentModel.frame.size.height - 14 + TGRetinaPixel, 12, 11);
    
    if (_checkSecondModel != nil)
        _checkSecondModel.frame = CGRectMake((_checkSecondEmbeddedInContent ? 0.0f : stateOffset.x) + _contentModel.frame.size.width - 13, (_checkSecondEmbeddedInContent ? 0.0f : stateOffset.y) + _contentModel.frame.size.height - 14 + TGRetinaPixel, 12, 11);
    
    if (_unsentButtonModel != nil)
    {
        _unsentButtonModel.frame = CGRectMake(containerSize.width - _unsentButtonModel.frame.size.width - 9, backgroundFrame.size.height + topSpacing + bottomSpacing - _unsentButtonModel.frame.size.height - ((_collapseFlags & TGModernConversationItemCollapseBottom) ? 5 : 6), _unsentButtonModel.frame.size.width, _unsentButtonModel.frame.size.height);
    }
    
    CGFloat replyButtonsHeight = 0.0f;
    if (_replyButtonsModel != nil) {
        CGRect backgroundFrame = _backgroundModel.frame;
        CGFloat backgroundExtension = 5.0f;
        
        [_replyButtonsModel layoutForContainerSize:CGSizeMake(MIN(MAX([_replyButtonsModel minimumWidth], backgroundFrame.size.width + backgroundExtension), containerSize.width - 44.0f), containerSize.height)];
        
        _replyButtonsModel.frame = CGRectMake((_incomingAppearance ? backgroundFrame.origin.x : (CGRectGetMaxX(backgroundFrame) - _replyButtonsModel.frame.size.width)) + (_backgroundModel == nil ? (_incomingAppearance ? -5.0f : 5.0f) : 0.0f), CGRectGetMaxY(backgroundFrame), _replyButtonsModel.frame.size.width, _replyButtonsModel.frame.size.height);
        replyButtonsHeight = _replyButtonsModel.frame.size.height;
        self.avatarOffset = replyButtonsHeight;
    }
    
    self.frame = CGRectMake(0, 0, containerSize.width, backgroundFrame.size.height + topSpacing + bottomSpacing + replyButtonsHeight);
    
    bool tiledMode = _contentModel.frame.size.height > TGModernFlatteningViewModelTilingLimit;
    [_contentModel setTiledMode:tiledMode];
    self.needsRelativeBoundsUpdates = tiledMode;
    
    if (updateContents)
    {
        [_contentModel setNeedsSubmodelContentsUpdate];
        [_contentModel updateSubmodelContentsIfNeeded];
    }
    
    [super layoutForContainerSize:containerSize];
}

- (void)updateAssets {
    [super updateAssets];
    
    _shareButtonModel.image = [[TGTelegraphConversationMessageAssetsSource instance] systemShareButton];
}

- (void)sharePressed {
    [_context.companionHandle requestAction:@"fastForwardMessage" options:@{@"mid": @(_mid)}];
}

- (void)imageDataInvalidated:(NSString *)imageUrl {
    [_webPageFooterModel imageDataInvalidated:imageUrl];
}

- (void)stopInlineMedia:(int32_t)excludeMid
{
    [_webPageFooterModel stopInlineMedia:excludeMid];
}

- (void)resumeInlineMedia {
    [_webPageFooterModel resumeInlineMedia];
}

@end
