#import "TGRoundMessageViewModel.h"

#import "TGTelegraph.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGDateUtils.h"
#import "TGPeerIdAdapter.h"
#import "TGTimerTarget.h"

#import "TGMessage.h"
#import "TGDocumentMediaAttachment.h"
#import "TGPreparedLocalDocumentMessage.h"
#import "TGPreparedLocalVideoMessage.h"

#import "TGVideoDownloadActor.h"

#import "TGContentBubbleViewModel.h"
#import "TGMessageImageViewModel.h"
#import "TGModernFlatteningViewModel.h"
#import "TGVideoMessageViewModel.h"
#import "TGReplyHeaderModel.h"
#import "TGModernImageViewModel.h"
#import "TGModernTextViewModel.h"
#import "TGModernButtonViewModel.h"
#import "TGRoundMessageRingViewModel.h"

#import "TGDoubleTapGestureRecognizer.h"

#import "TGTelegraphConversationMessageAssetsSource.h"
#import "TGMessageImageView.h"
#import "TGReusableLabel.h"
#import "TGModernConversationItem.h"
#import "TGModernViewContext.h"
#import "TGModernButtonView.h"

#import "TGMusicPlayer.h"
#import "TGNativeAudioPlayer.h"

#import "TGMediaVideoConverter.h"
#import "TGVideoMessagePIPController.h"

#import "TGMessageReplyButtonsModel.h"

@interface TGRoundMessageViewModel () <TGDoubleTapGestureRecognizerDelegate, UIGestureRecognizerDelegate, TGMessageImageViewDelegate>
{
    TGMessage *_message;
    bool _incoming;
    bool _incomingAppearance;
    bool _read;
    int _date;
    TGMessageDeliveryState _deliveryState;
    bool _hasAvatar;
    
    bool _isMessageViewed;
    NSTimeInterval _messageViewDate;
    int32_t _messageLifetime;
    NSTimer *_viewDateTimer;
    
    bool _mediaIsAvailable;
    bool _canDownload;
    bool _activatedMedia;
    bool _boundToContainer;
    
    float _progress;
    bool _progressVisible;
    
    bool _muted;
    bool _isSecret;
    bool _playing;
    
    id<SDisposable> _playingVideoMessageIdDisposable;
    
    TGMusicPlayerStatus *_status;
    TGVideoMediaAttachment *_video;
    
    NSString *_legacyThumbnailCacheUri;
    
    TGModernImageViewModel *_backgroundModel;
    
    UITapGestureRecognizer *_tapGestureRecognizer;
    TGDoubleTapGestureRecognizer *_boundDoubleTapRecognizer;
    UITapGestureRecognizer *_headerTapRecognizer;
    
    TGModernImageViewModel *_muteButtonModel;
    
    TGModernImageViewModel *_unsentButtonModel;
    UITapGestureRecognizer *_unsentButtonTapRecognizer;
    
    TGModernButtonViewModel *_shareButtonModel;
    
    TGModernFlatteningViewModel *_contentModel;
    TGModernImageViewModel *_headerBackgroundModel;
    TGReplyHeaderModel *_replyHeaderModel;
    TGModernTextViewModel *_replyHeaderViaUserModel;
    
    int64_t _forwardedPeerId;
    int64_t _forwardedMessageId;
    
    TGModernTextViewModel *_forwardedHeaderModel;
    
    TGRoundMessageRingViewModel *_ringModel;
    
    UIImageView *_temporaryHighlightView;
    
    int32_t _replyMessageId;
    TGMessageViewCountContentProperty *_messageViews;
    NSString *_authorSignature;
    
    TGMessageReplyButtonsModel *_replyButtonsModel;
    TGBotReplyMarkup *_replyMarkup;
    SMetaDisposable *_callbackButtonInProgressDisposable;
}

@property (nonatomic, strong) TGMessageImageViewModel *imageModel;

@property (nonatomic, assign) bool isSecretMedia;

@end

@implementation TGRoundMessageViewModel

- (instancetype)initWithMessage:(TGMessage *)message video:(TGVideoMediaAttachment *)video authorPeer:(id)authorPeer context:(TGModernViewContext *)context forwardPeer:(id)forwardPeer forwardAuthor:(id)forwardAuthor forwardMessageId:(int32_t)forwardMessageId replyHeader:(TGMessage *)replyHeader replyPeer:(id)replyPeer
{
    TGImageInfo *imageInfo = video.thumbnailInfo;
    TGImageInfo *previewImageInfo = imageInfo;
    
    NSString *legacyVideoFilePath = [TGVideoMessageViewModel filePathForVideoId:video.videoId != 0 ? video.videoId : video.localVideoId local:video.videoId == 0];
    NSString *legacyThumbnailCacheUri = [imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];

    
    CGSize roundSize = [TGRoundMessageViewModel roundSize];

    CGSize renderSize = CGSizeZero;
    [imageInfo imageUrlForLargestSize:&renderSize];
    renderSize = TGScaleToFill(renderSize, roundSize);
    
    if (video.videoId != 0 || video.localVideoId != 0)
    {
        previewImageInfo = [[TGImageInfo alloc] init];
        
        NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"video-thumbnail://?"];
        if (video.videoId != 0)
            [previewUri appendFormat:@"id=%" PRId64 "", video.videoId];
        else
            [previewUri appendFormat:@"local-id=%" PRId64 "", video.localVideoId];
        
        [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)roundSize.width, (int)roundSize.height, (int)renderSize.width, (int)renderSize.height];
        
        [previewUri appendFormat:@"&legacy-video-file-path=%@", legacyVideoFilePath];
        if (legacyThumbnailCacheUri != nil)
            [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
        
        if (message.messageLifetime > 0 && message.messageLifetime <= 60 && message.layer >= 17)
            [previewUri appendString:@"&secret=1"];
        
        [previewUri appendFormat:@"&flat=1&cornerRadius=%dinset=4", (int)(roundSize.width / 2.0f)];
        
        [previewImageInfo addImageWithSize:renderSize url:previewUri];
    }
    
    self = [super initWithAuthorPeer:authorPeer context:context];
    if (self != nil)
    {
        _mid = message.mid;
        _message = message;
        _video = video;
    
        _isSecret = TGPeerIdIsSecretChat(message.cid);
        self.isSecretMedia = (message.messageLifetime > 0 && message.messageLifetime <= 60 && message.layer >= 17);
        
        _incoming = !message.outgoing;
        _read = ![_context isMessageUnread:message];
        _deliveryState = message.deliveryState;
        _date = (int32_t)message.date;
        _messageViews = message.viewCount;
        _messageLifetime = message.messageLifetime;
        
        self.avatarOffset = 2.0f;
        
        _hasAvatar = authorPeer != nil && [authorPeer isKindOfClass:[TGUser class]];
        if ([authorPeer isKindOfClass:[TGConversation class]]) {
            if ([context isAdminLog]) {
                _hasAvatar = true;
            }
        }
        _needsEditingCheckButton = true;
        
        _canDownload = video.videoId != 0;
        _incomingAppearance = _incoming || [authorPeer isKindOfClass:[TGConversation class]];
        
        CGFloat scale = [UIScreen mainScreen].scale;
        static dispatch_once_t onceToken;
        static UIImage *backgroundImage;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(roundSize, false, 0.0f);
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextSetStrokeColorWithColor(context, UIColorRGBA(0x86a9c9, 0.5f).CGColor);
            CGContextSetLineWidth(context, TGScreenPixel);
            
            CGRect rect = CGRectInset(CGRectMake(0.0f, 0.0f, roundSize.width, roundSize.height), TGScreenPixel, TGScreenPixel);
            CGContextFillEllipseInRect(context, rect);
            CGContextStrokeEllipseInRect(context, rect);

            backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        _backgroundModel = [[TGModernImageViewModel alloc] initWithImage:backgroundImage];
        [self addSubmodel:_backgroundModel];
        
        NSString *imageUri = [previewImageInfo imageUrlForLargestSize:NULL];
        
        _imageModel = [[TGMessageImageViewModel alloc] initWithUri:imageUri];
        _imageModel.skipDrawInContext = true;
        [_imageModel setBlurlessOverlay:true];
        if ([imageUri hasPrefix:@"video-thumbnail://?"])
        {
            NSDictionary *dict = [TGStringUtils argumentDictionaryInUrlString:[imageUri substringFromIndex:@"video-thumbnail://?".length]];
            _legacyThumbnailCacheUri = dict[@"legacy-thumbnail-cache-url"];
        }
        
        _imageModel.overlayBackgroundColorHint = UIColorRGBA(0x000000, 0.4f);

        CGFloat inset = 2.0f;
        if (TGScreenScaling() == 2.0f)
            inset = 2.5f;
        else if (TGScreenScaling() == 1.0f)
            inset = 3.5f;
        
        _imageModel.inlineVideoSize = CGSizeMake(roundSize.width * scale, roundSize.height * scale);
        _imageModel.inlineVideoCornerRadius = (roundSize.width - inset * 2) / 2.0f;
        _imageModel.inlineVideoInsets = UIEdgeInsetsZero;
        [self addSubmodel:_imageModel];
        
        if (_incoming || (TGPeerIdIsChannel(message.cid) && !context.conversation.isChannelGroup))
        {
            [_imageModel setTimestampOffset:CGPointMake(-34.0f, 8.0f)];
            [_imageModel setTimestampPosition:TGMessageImageViewTimestampPositionRightLong];
        }
        else
        {
            [_imageModel setTimestampOffset:CGPointMake(8.0f, 8.0f)];
        }
        
        _imageModel.flexibleTimestamp = true;
        [_imageModel setTimestampString:[self timestampString] signatureString:_authorSignature displayCheckmarks:!_incoming && _deliveryState != TGMessageDeliveryStateFailed checkmarkValue:(_incoming ? 0 : ((_deliveryState == TGMessageDeliveryStateDelivered ? 1 : 0) + (_read ? 1 : 0))) displayViews:_messageViews != nil viewsValue:_messageViews.viewCount animated:false];
        [_imageModel setDisplayTimestampProgress:_deliveryState == TGMessageDeliveryStatePending];
        _imageModel.timestampHidden = false;
        
        [self updateAdditionalDataString];
        [_imageModel setTimestampColor:[[TGTelegraphConversationMessageAssetsSource instance] systemMessageBackgroundColor]];
        
        if (_messageLifetime != 0 && message.layer >= 17)
        {
            _isMessageViewed = [context isSecretMessageViewed:_mid];
            _messageViewDate = [context secretMessageViewDate:_mid];
        }
        
        if (!_incoming)
        {
            if (_deliveryState == TGMessageDeliveryStateFailed)
            {
                [self addSubmodel:[self unsentButtonModel]];
            }
        }
        
        _muteButtonModel = [[TGModernImageViewModel alloc] init];
        _muteButtonModel.accountForTransform = true;
        [_muteButtonModel setImage:[[TGTelegraphConversationMessageAssetsSource instance] systemUnmuteButton]];
        [self addSubmodel:_muteButtonModel];
        
        [self _updateMuted:true];
        
        if (replyHeader != nil || forwardPeer != nil)
        {
            _replyMessageId = replyHeader.mid;
            
            _headerBackgroundModel = [[TGModernImageViewModel alloc] initWithImage:[[TGTelegraphConversationMessageAssetsSource instance] systemReplyBackground]];
            _headerBackgroundModel.skipDrawInContext = true;
            [self addSubmodel:_headerBackgroundModel];
            
            _contentModel = [[TGModernFlatteningViewModel alloc] init];
            [self addSubmodel:_contentModel];
            
            if (replyHeader != nil)
            {
                _replyHeaderModel = [TGContentBubbleViewModel replyHeaderModelFromMessage:replyHeader peer:replyPeer incoming:_incomingAppearance system:true];
                [_contentModel addSubmodel:_replyHeaderModel];
            }
            else
            {
                [self setForwardHeader:forwardPeer forwardAuthor:forwardAuthor messageId:forwardMessageId];
                [_contentModel addSubmodel:_forwardedHeaderModel];
            }
        }
        
        _ringModel = [[TGRoundMessageRingViewModel alloc] init];
        _ringModel.viewUserInteractionDisabled = true;
        [self addSubmodel:_ringModel];
        
        bool forwardedFromChannel = false;
        
        if (_incomingAppearance && [forwardPeer isKindOfClass:[TGConversation class]]) {
            TGConversation *conversation = forwardPeer;
            if (conversation.isChannel && !conversation.isChannelGroup) {
                forwardedFromChannel = true;
            }
        }
        
        bool isChannel = [authorPeer isKindOfClass:[TGConversation class]];
        bool isBot = false;
        if ([authorPeer isKindOfClass:[TGUser class]]) {
            if (((TGUser *)authorPeer).kind == TGUserKindBot || ((TGUser *)authorPeer).kind ==  TGUserKindSmartBot) {
                isBot = true;
            }
        }
        
        if (_incomingAppearance && (isChannel || _context.isBot || (_context.isPublicGroup) || isBot || forwardedFromChannel) && !_context.isAdminLog) {
            _shareButtonModel = [[TGModernButtonViewModel alloc] init];
            _shareButtonModel.image = [[TGTelegraphConversationMessageAssetsSource instance] systemShareButton];
            _shareButtonModel.modernHighlight = true;
            _shareButtonModel.frame = CGRectMake(0.0f, 0.0f, 29.0f, 29.0f);
            [self addSubmodel:_shareButtonModel];
        }
        
        TGBotReplyMarkup *replyMarkup = message.replyMarkup;
        if (replyMarkup != nil && replyMarkup.isInline) {
            _replyMarkup = replyMarkup;
            _replyButtonsModel = [[TGMessageReplyButtonsModel alloc] init];
            __weak TGRoundMessageViewModel *weakSelf = self;
            _replyButtonsModel.buttonActivated = ^(TGBotReplyMarkupButton *button, NSInteger index) {
                __strong TGRoundMessageViewModel *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{@"mid": @(strongSelf->_mid), @"command": button.text}];
                    if (button.action != nil) {
                        dict[@"action"] = button.action;
                    }
                    dict[@"index"] = @(index);
                    [strongSelf->_context.companionHandle requestAction:@"activateCommand" options:dict];
                }
            };
            [_replyButtonsModel setReplyMarkup:replyMarkup hasReceipt:false];
            [self addSubmodel:_replyButtonsModel];
        }
    }
    return self;
}

- (void)dealloc
{
}

+ (CGSize)roundSize
{
    static dispatch_once_t onceToken;
    static CGSize size;
    dispatch_once(&onceToken, ^{
        if ([TGViewController hasLargeScreen] || [TGViewController hasVeryLargeScreen])
            size = CGSizeMake(214.0f, 214.0f);
        else
            size = CGSizeMake(184.0f, 184.0f);
    });
    return size;
}

- (void)setIsSecretMedia:(bool)isSecretMedia
{
    _isSecretMedia = isSecretMedia;
    
    [self updateImageOverlay:false];
}

- (void)setAuthorSignature:(NSString *)authorSignature {
    _authorSignature = authorSignature;
    [_imageModel setTimestampString:[self timestampString] signatureString:_authorSignature displayCheckmarks:!_incoming && _deliveryState != TGMessageDeliveryStateFailed checkmarkValue:(_incoming ? 0 : ((_deliveryState == TGMessageDeliveryStateDelivered ? 1 : 0) + (_read ? 1 : 0))) displayViews:_messageViews != nil viewsValue:_messageViews.viewCount animated:false];
}

- (void)updateAdditionalDataString
{
    TGVideoMediaAttachment *video = nil;
    for (TGMediaAttachment *attachment in _message.mediaAttachments)
    {
        if (attachment.type == TGVideoMediaAttachmentType)
        {
            video = (TGVideoMediaAttachment *)attachment;
            break;
        }
    }
    
    int32_t value = _status ? (int32_t)(_status.duration - _status.offset * _status.duration) : video.duration;
    int32_t minutes = value / 60;
    int32_t seconds = value % 60;
    
    bool listenedStatus = true;
    if (_isSecret) {
        listenedStatus = [_context isSecretMessageViewed:_message.mid];
    } else {
        listenedStatus = !_context.viewStatusEnabled || _message.contentProperties[@"contentsRead"] != nil;
    }
    
    NSString *string = [[NSString alloc] initWithFormat:@"%d:%02d", minutes, seconds];
    if (!listenedStatus)
        string = [string stringByAppendingString:@" ∙"];
    
    [_imageModel setAdditionalDataString:string];
    [_imageModel setAdditionalDataPosition:TGMessageImageViewTimestampPositionLeftBottom];
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

- (void)imageDataInvalidated:(NSString *)imageUrl
{
    if ([_legacyThumbnailCacheUri isEqualToString:imageUrl])
    {
        [_imageModel reloadImage:false];
    }
}

- (void)updateMediaAvailability:(bool)mediaIsAvailable viewStorage:(TGModernViewStorage *)viewStorage delayDisplay:(bool)delayDisplay
{
    bool wasAvailable = _mediaIsAvailable;
    [super updateMediaAvailability:mediaIsAvailable viewStorage:viewStorage delayDisplay:delayDisplay];
    _mediaIsAvailable = mediaIsAvailable;
    
    _muteButtonModel.hidden = (!_mediaIsAvailable && _canDownload);
    
    if (!wasAvailable && mediaIsAvailable && _boundToContainer) {
        if ([self.imageModel boundView] != nil && _mediaIsAvailable) {
            [self activateMediaPlayback];
        }
    }
    
    if (mediaIsAvailable || !delayDisplay) {
        [self updateImageOverlay:false];
    }
}

- (NSString *)timestampString
{
    return [TGDateUtils stringForShortTime:_date];
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated
{
    [super updateMessage:message viewStorage:viewStorage sizeUpdated:sizeUpdated];
    
    TGVideoMediaAttachment *video = nil;
    for (TGMediaAttachment *attachment in message.mediaAttachments)
    {
        if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
        {
            video = (TGVideoMediaAttachment *)attachment;
            break;
        }
    }
    
    if (video != nil)
        _video = video;
    
    bool wasLocal = !_canDownload;
    _canDownload = _video.videoId != 0;
    
    if ([self.imageModel boundView] != nil && _mediaIsAvailable) {
        [self activateMediaPlayback];
    }
    
    if (_canDownload && wasLocal) {
        TGImageInfo *imageInfo = video.thumbnailInfo;
        TGImageInfo *previewImageInfo = imageInfo;
        
        NSString *legacyVideoFilePath = [TGVideoMessageViewModel filePathForVideoId:video.videoId != 0 ? video.videoId : video.localVideoId local:video.videoId == 0];
        NSString *legacyThumbnailCacheUri = [imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
        
        CGSize roundSize = [TGRoundMessageViewModel roundSize];
        
        CGSize renderSize = CGSizeZero;
        [imageInfo imageUrlForLargestSize:&renderSize];
        renderSize = TGScaleToFill(renderSize, roundSize);
        
        if (video.videoId != 0 || video.localVideoId != 0)
        {
            previewImageInfo = [[TGImageInfo alloc] init];
            
            NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"video-thumbnail://?"];
            if (video.videoId != 0)
                [previewUri appendFormat:@"id=%" PRId64 "", video.videoId];
            else
                [previewUri appendFormat:@"local-id=%" PRId64 "", video.localVideoId];
            
            [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)roundSize.width, (int)roundSize.height, (int)renderSize.width, (int)renderSize.height];
            
            [previewUri appendFormat:@"&legacy-video-file-path=%@", legacyVideoFilePath];
            if (legacyThumbnailCacheUri != nil)
                [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
            
            if (message.messageLifetime > 0 && message.messageLifetime <= 60 && message.layer >= 17)
                [previewUri appendString:@"&secret=1"];
            
            [previewUri appendFormat:@"&flat=1&cornerRadius=%dinset=4", (int)(roundSize.width / 2.0f)];
            
            [previewImageInfo addImageWithSize:renderSize url:previewUri];
        }
        
        NSString *imageUri = [previewImageInfo imageUrlForLargestSize:NULL];
        [_imageModel setUri:imageUri];
        if ([imageUri hasPrefix:@"video-thumbnail://?"])
        {
            NSDictionary *dict = [TGStringUtils argumentDictionaryInUrlString:[imageUri substringFromIndex:@"video-thumbnail://?".length]];
            _legacyThumbnailCacheUri = dict[@"legacy-thumbnail-cache-url"];
        }
    }
    
    [self updateImageOverlay:false];

    _mid = message.mid;
    _message = message;
    
    [self updateAdditionalDataString];
    
    bool messageUnread = [_context isMessageUnread:message];
    
    if (_deliveryState != _message.deliveryState || (!_incoming && _read != !messageUnread))
    {
        _deliveryState = message.deliveryState;
        _read = !messageUnread;
        
        [_imageModel setTimestampString:[self timestampString] signatureString:_authorSignature displayCheckmarks:!_incoming && _deliveryState != TGMessageDeliveryStateFailed checkmarkValue:(_incoming ? 0 : ((_deliveryState == TGMessageDeliveryStateDelivered ? 1 : 0) + (_read ? 1 : 0))) displayViews:_messageViews != nil viewsValue:_messageViews.viewCount animated:true];
        [_imageModel setDisplayTimestampProgress:_deliveryState == TGMessageDeliveryStatePending];
        
        if (_deliveryState == TGMessageDeliveryStateDelivered)
        {
            if (_unsentButtonModel != nil)
            {
                [self removeSubmodel:_unsentButtonModel viewStorage:viewStorage];
                _unsentButtonModel = nil;
            }
        }
        else if (_deliveryState == TGMessageDeliveryStateFailed)
        {
            if (_unsentButtonModel == nil)
            {
                [self addSubmodel:[self unsentButtonModel]];
                if ([_imageModel boundView] != nil)
                    [_unsentButtonModel bindViewToContainer:[_imageModel boundView].superview viewStorage:viewStorage];
                _unsentButtonModel.frame = CGRectOffset(_unsentButtonModel.frame, self.frame.size.width + _unsentButtonModel.frame.size.width, self.frame.size.height - _unsentButtonModel.frame.size.height - ((_collapseFlags & TGModernConversationItemCollapseBottom) ? 5 : 6));
                
                _unsentButtonTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unsentButtonTapGesture:)];
                [[_unsentButtonModel boundView] addGestureRecognizer:_unsentButtonTapRecognizer];
            }
            
            if (self.frame.size.width > FLT_EPSILON)
            {
                if ([_imageModel boundView] != nil)
                {
                    [UIView animateWithDuration:0.2 animations:^
                    {
                        [self layoutForContainerSize:CGSizeMake(self.frame.size.width, 0.0f)];
                    }];
                }
                else
                    [self layoutForContainerSize:CGSizeMake(self.frame.size.width, 0.0f)];
            }
        }
        else if (_deliveryState == TGMessageDeliveryStatePending)
        {
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
                            [[_imageModel boundView].superview addSubview:restoredView];
                            
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
                if ([_imageModel boundView] != nil)
                {
                    [UIView animateWithDuration:0.2 animations:^
                    {
                        [self layoutForContainerSize:CGSizeMake(self.frame.size.width, 0.0f)];
                    }];
                }
                else
                    [self layoutForContainerSize:CGSizeMake(self.frame.size.width, 0.0f)];
            }
        }
    }
    
    TGBotReplyMarkup *replyMarkup = message.replyMarkup != nil && message.replyMarkup.isInline ? message.replyMarkup : nil;
    if (!TGObjectCompare(_replyMarkup, replyMarkup)) {
        _replyMarkup = replyMarkup;
        
        if (_replyButtonsModel == nil) {
            _replyButtonsModel = [[TGMessageReplyButtonsModel alloc] init];
            __weak TGRoundMessageViewModel *weakSelf = self;
            _replyButtonsModel.buttonActivated = ^(TGBotReplyMarkupButton *button, NSInteger index) {
                __strong TGRoundMessageViewModel *strongSelf = weakSelf;
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
        if (_imageModel.boundView != nil) {
            [_replyButtonsModel unbindView:viewStorage];
            [_replyButtonsModel setReplyMarkup:replyMarkup hasReceipt:false];
            [_replyButtonsModel bindViewToContainer:_imageModel.boundView.superview viewStorage:viewStorage];
        } else {
            [_replyButtonsModel setReplyMarkup:replyMarkup hasReceipt:false];
        }
        if (sizeUpdated) {
            *sizeUpdated = true;
        }
    }
}

- (void)updateMessageAttributes
{
    [super updateMessageAttributes];
    
    bool previousRead = _read;
    _read = ![_context isMessageUnread:_message];
    if (previousRead != _read) {
        [_imageModel setTimestampString:[self timestampString] signatureString:_authorSignature displayCheckmarks:!_incoming && _deliveryState != TGMessageDeliveryStateFailed checkmarkValue:(_incoming ? 0 : ((_deliveryState == TGMessageDeliveryStateDelivered ? 1 : 0) + (_read ? 1 : 0))) displayViews:_messageViews != nil viewsValue:_messageViews.viewCount animated:true];
    }
    
    if (_isSecret)
        [self updateAdditionalDataString];
    
    if (self.isSecretMedia)
    {
        bool isMessageViewed = [_context isSecretMessageViewed:_mid];
        NSTimeInterval messageViewDate = [_context secretMessageViewDate:_mid];
        
        if (_isMessageViewed != isMessageViewed || ABS(_messageViewDate - messageViewDate) > DBL_EPSILON)
        {
            _isMessageViewed = isMessageViewed;
            _messageViewDate = messageViewDate;
            
            [self updateImageOverlay:false];
            
            if (_incoming && ABS(_messageViewDate) > DBL_EPSILON)
                [self _updateViewDateTimerIfVisible];
        }
    }
}

- (void)_updateViewDateTimerIfVisible
{
    [_viewDateTimer invalidate];
    _viewDateTimer = nil;
    
    if (_isMessageViewed && _incoming && ABS(_messageViewDate) > DBL_EPSILON && _imageModel.boundView != nil)
    {
        [self updateImageOverlay:true];
        
        _viewDateTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(_updateViewDateTimerIfVisible) interval:0.5 repeat:false runLoopModes:NSRunLoopCommonModes];
    }
}

- (void)_invalidateViewDateTimer
{
    [_viewDateTimer invalidate];
    _viewDateTimer = nil;
}

- (void)updateImageInfo:(TGImageInfo *)imageInfo
{
    NSString *imageUri = [imageInfo imageUrlForLargestSize:NULL];
    if ([imageUri hasPrefix:@"photo-thumbnail://?"])
    {
        NSDictionary *dict = [TGStringUtils argumentDictionaryInUrlString:[imageUri substringFromIndex:@"photo-thumbnail://?".length]];
        _legacyThumbnailCacheUri = dict[@"legacy-thumbnail-cache-url"];
    }
    else if ([imageUri hasPrefix:@"video-thumbnail://?"])
    {
        NSDictionary *dict = [TGStringUtils argumentDictionaryInUrlString:[imageUri substringFromIndex:@"video-thumbnail://?".length]];
        _legacyThumbnailCacheUri = dict[@"legacy-thumbnail-cache-url"];
    }
    else if ([imageUri hasPrefix:@"animation-thumbnail://?"])
    {
        NSDictionary *dict = [TGStringUtils argumentDictionaryInUrlString:[imageUri substringFromIndex:@"animation-thumbnail://?".length]];
        _legacyThumbnailCacheUri = dict[@"legacy-thumbnail-cache-url"];
    }
    
    [_imageModel setUri:imageUri];
}

- (void)updateAssets {
    [super updateAssets];
    
    _shareButtonModel.image = [[TGTelegraphConversationMessageAssetsSource instance] systemShareButton];
}

- (void)updateImageOverlay:(bool)animated
{
    if (_progressVisible)
    {
        [_imageModel setOverlayType:TGMessageImageViewOverlayProgress animated:false];
        [_imageModel setProgress:_progress animated:animated];
    }
    else if (!_mediaIsAvailable)
    {
        if (_canDownload) {
            [_imageModel setOverlayType:TGMessageImageViewOverlayDownload animated:false];
        } else {
            [_imageModel setOverlayType:TGMessageImageViewOverlayNone animated:false];
        }
        [_imageModel setProgress:0.0f animated:false];
    }
    else
    {
        if (self.isSecretMedia && _isMessageViewed && _incoming && !_playing && ABS(_messageViewDate) > DBL_EPSILON)
        {
            NSTimeInterval endTime = _messageViewDate + _messageLifetime;
            int remainingSeconds = MAX(0, (int)(endTime - CFAbsoluteTimeGetCurrent()));
            
            [_imageModel setSecretProgress:(CGFloat)remainingSeconds / (CGFloat)_messageLifetime completeDuration:_messageLifetime animated:animated];
            [_imageModel setOverlayType:TGMessageImageViewOverlaySecretProgress];
        }
        else
        {
            [_imageModel setOverlayType:[self defaultOverlayActionType] animated:animated];
        }
    }
}

- (int)defaultOverlayActionType
{
    return _isSecretMedia ? (_isMessageViewed || _playing ? TGMessageImageViewOverlayNone : TGMessageImageViewOverlaySecret) : TGMessageImageViewOverlayNone;
}

- (void)updateProgress:(bool)progressVisible progress:(float)progress viewStorage:(TGModernViewStorage *)__unused viewStorage animated:(bool)animated
{
    [super updateProgress:progressVisible progress:progress viewStorage:viewStorage animated:animated];
    
    bool progressWasVisible = _progressVisible;
    float previousProgress = _progress;
    
    _progress = progress;
    _progressVisible = progressVisible;
    
    [self updateImageOverlay:((progressWasVisible && !_progressVisible) || (_progressVisible && ABS(_progress - previousProgress) > FLT_EPSILON)) && animated];
}

- (void)updateAnimationsEnabled
{
}

- (void)stopInlineMedia:(int32_t)__unused excludeMid
{
    bool wasActivated = _activatedMedia;
    _activatedMedia = false;
    
    if (wasActivated)
    {
        [((TGMessageImageViewContainer *)self.imageModel.boundView).imageView hideVideo];
        [((TGMessageImageViewContainer *)self.imageModel.boundView).imageView setVideoPathSignal:nil];
    }
    
    [self updateImageOverlay:false];
}

- (void)resumeInlineMedia
{
    if (_mediaIsAvailable && !_activatedMedia) {
        [self activateMediaPlayback];
    }
}

- (CGSize)minimumImageSizeForMessage:(TGMessage *)__unused message
{
    return CGSizeMake(130, 130);
}

- (void)updateMediaVisibility
{
    _imageModel.mediaVisible = [_context isMediaVisibleInMessage:_mid];
}

- (void)subscribeStatus {
    [_playingVideoMessageIdDisposable dispose];
    if (_context.playingAudioMessageStatus != nil)
    {
        __weak TGRoundMessageViewModel *weakSelf = self;
        _playingVideoMessageIdDisposable = [_context.playingAudioMessageStatus startWithNext:^(TGMusicPlayerStatus *status)
        {
            __strong TGRoundMessageViewModel *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                TGMessageImageView *imageView = ((TGMessageImageViewContainer *)strongSelf.imageModel.boundView).imageView;
                if (status == nil || !status.isVoice)
                {
                    strongSelf->_status = nil;
                    strongSelf->_playing = false;
                    
                    [imageView setVideoView:nil];
                    [strongSelf activateMediaPlayback];
                    
                    [strongSelf->_ringModel setStatus:nil];
                    
                    [strongSelf _updateMuted:true];
                }
                else
                {
                    [strongSelf stopInlineMedia:0];
                    
                    if ([(NSNumber *)status.item.key intValue] == strongSelf->_mid)
                    {
                        strongSelf->_status = status;
                        strongSelf->_playing = true;
                        
                        [imageView setVideoView:[TGVideoMessagePIPController videoViewForStatus:status]];
                        [strongSelf->_ringModel setStatus:status];
                        
                        [strongSelf _updateMuted:false];
                    }
                    else
                    {
                        strongSelf->_status = nil;
                        strongSelf->_playing = false;
                     
                        [imageView setVideoView:nil];
                        [strongSelf->_ringModel setStatus:nil];
                        
                        [strongSelf _updateMuted:true];
                    }
                }
                [strongSelf updateAdditionalDataString];
                [strongSelf updateImageOverlay:false];
            }
        }];
    }
}

- (void)updateMessageVisibility
{
    TGMessageImageView *imageView = ((TGMessageImageViewContainer *)_imageModel.boundView).imageView;
    [imageView setVideoView:[TGVideoMessagePIPController videoViewForStatus:_status]];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage {
    [self updateEditingState:nil viewStorage:nil animationDelay:-1.0];
    
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    _boundToContainer = true;
    
    ((TGMessageImageViewContainer *)[_imageModel boundView]).imageView.delegate = self;
    
    [self updateMediaVisibility];
    
    if (_mediaIsAvailable) {
        [self activateMediaPlayback];
    }
    
    [_replyHeaderModel bindSpecialViewsToContainer:_contentModel.boundView viewStorage:viewStorage atItemPosition:CGPointMake(_replyHeaderModel.frame.origin.x, _replyHeaderModel.frame.origin.y)];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageTapGesture:)];
    _tapGestureRecognizer.delegate = self;
    
    _boundDoubleTapRecognizer = [[TGDoubleTapGestureRecognizer alloc] initWithTarget:self action:@selector(messageDoubleTapGesture:)];
    _boundDoubleTapRecognizer.consumeSingleTap = false;
    _boundDoubleTapRecognizer.delegate = self;
    
    [_imageModel.boundView addGestureRecognizer:_tapGestureRecognizer];
    [_imageModel.boundView addGestureRecognizer:_boundDoubleTapRecognizer];
    
    if (_contentModel != nil)
    {
        if (_replyHeaderModel != nil)
        {
            _headerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(replyHeaderTapGesture:)];
            [[_contentModel boundView] addGestureRecognizer:_headerTapRecognizer];
        }
        else if (_forwardedHeaderModel != nil)
        {
            _headerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forwardHeaderTapGesture:)];
            [[_contentModel boundView] addGestureRecognizer:_headerTapRecognizer];
        }
    }
    
    if (_unsentButtonModel != nil)
    {
        _unsentButtonTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unsentButtonTapGesture:)];
        [[_unsentButtonModel boundView] addGestureRecognizer:_unsentButtonTapRecognizer];
    }
    
    if (_shareButtonModel != nil) {
        [(TGModernButtonView *)_shareButtonModel.boundView addTarget:self action:@selector(sharePressed) forControlEvents:UIControlEventTouchUpInside];
    }

    [self subscribeStatus];
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition {
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
    
    _boundToContainer = false;
    
     [_replyButtonsModel bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:CGPointMake(itemPosition.x, itemPosition.y)];
    
    [self subscribeStatus];
    [self subscribeToCallbackButtonInProgress];
}

- (void)subscribeToCallbackButtonInProgress {
    if (_replyButtonsModel != nil) {
        __weak TGRoundMessageViewModel *weakSelf = self;
        [_callbackButtonInProgressDisposable setDisposable:[[[_context callbackInProgress] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *next) {
            __strong TGRoundMessageViewModel *strongSelf = weakSelf;
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
    _boundToContainer = false;
    
    _status = nil;
    _playing = false;
    [_playingVideoMessageIdDisposable dispose];
    _playingVideoMessageIdDisposable = nil;
    
    ((TGMessageImageViewContainer *)[_imageModel boundView]).imageView.delegate = nil;
    
    [((TGMessageImageViewContainer *)self.imageModel.boundView).imageView setVideoPathSignal:nil];
    [((TGMessageImageViewContainer *)self.imageModel.boundView).imageView setVideoView:nil];
    _activatedMedia = false;

    [self _updateMuted:true];
    
    UIView *imageView = [_imageModel boundView];
    [imageView removeGestureRecognizer:_tapGestureRecognizer];
    _tapGestureRecognizer.delegate = nil;
    _tapGestureRecognizer = nil;
    
    [imageView removeGestureRecognizer:_boundDoubleTapRecognizer];
    _boundDoubleTapRecognizer.delegate = nil;
    _boundDoubleTapRecognizer = nil;
    
    [[_contentModel boundView] removeGestureRecognizer:_headerTapRecognizer];
    _headerTapRecognizer = nil;
    
    if (_temporaryHighlightView != nil)
    {
        [_temporaryHighlightView removeFromSuperview];
        _temporaryHighlightView = nil;
    }
    
    if (_unsentButtonModel != nil)
    {
        [[_unsentButtonModel boundView] removeGestureRecognizer:_unsentButtonTapRecognizer];
        _unsentButtonTapRecognizer = nil;
    }
    
    if (_shareButtonModel != nil)
    {
        [(TGModernButtonView *)_shareButtonModel.boundView removeTarget:self action:@selector(sharePressed) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self _invalidateViewDateTimer];
    
    [super unbindView:viewStorage];
    
    [self updateImageOverlay:false];
}

- (void)activateMedia
{
    if (!_activatedMedia)
        [self activateMediaPlayback];
}

- (void)sharePressed {
    [_context.companionHandle requestAction:@"fastForwardMessage" options:@{@"mid": @(_mid)}];
}

- (void)activateMediaPlayback
{
    if (_isSecretMedia || !_boundToContainer)
        return;
    
    bool wasActivated = _activatedMedia;
    [self updateImageOverlay:false];

    NSString *videoPath = [TGVideoDownloadActor localPathForVideoUrl:[_video.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:NULL]];
    if (!wasActivated && videoPath != nil && [[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
         _activatedMedia = true;
        [((TGMessageImageViewContainer *)self.imageModel.boundView).imageView setVideoPathSignal:[SSignal single:videoPath]];
    }
}

- (CGRect)effectiveContentFrame
{
    return _imageModel.frame;
}

- (void)_updateMuted:(bool)muted
{
    if (muted == _muted)
        return;
    
    _muted = muted;
    
    if (_muteButtonModel.boundView != nil)
    {
        UIView *muteButtonView = _muteButtonModel.boundView;
        [muteButtonView.layer removeAllAnimations];
        
        if ((muteButtonView.transform.a < 0.3f || muteButtonView.transform.a > 1.0f) || muteButtonView.alpha < FLT_EPSILON)
        {
            muteButtonView.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
            muteButtonView.alpha = 0.0f;
        }
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | 7 << 16 animations:^
        {
            muteButtonView.transform = muted ? CGAffineTransformIdentity : CGAffineTransformMakeScale(0.001f, 0.001f);
        } completion:nil];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            muteButtonView.alpha = muted ? 1.0f : 0.0f;
        } completion:nil];
    }
    else
    {
        [_muteButtonModel setAlpha:_muted ? 1.0f : 0.0f];
    }
}

- (void)setTemporaryHighlighted:(bool)temporaryHighlighted viewStorage:(TGModernViewStorage *)__unused viewStorage
{
    if (iosMajorVersion() >= 7)
    {
        UIImage *image = _backgroundModel.image;
        if (image != nil)
        {
            if (temporaryHighlighted)
            {
                if (_temporaryHighlightView == nil)
                {
                    UIImage *highlightImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    _temporaryHighlightView = [[UIImageView alloc] initWithImage:highlightImage];
                    _temporaryHighlightView.frame = CGRectInset([_imageModel boundView].bounds, -2.0f, -2.0f);
                    _temporaryHighlightView.tintColor = UIColorRGBA(0xffffff, 0.7f);
                    [[_imageModel boundView] addSubview:_temporaryHighlightView];
                }
            }
            else if (_temporaryHighlightView != nil)
            {
                UIImageView *temporaryView = _temporaryHighlightView;
                [UIView animateWithDuration:0.4 animations:^
                {
                    temporaryView.alpha = 0.0f;
                } completion:^(__unused BOOL finished)
                {
                    [temporaryView removeFromSuperview];
                }];
                _temporaryHighlightView = nil;
            }
        }
    }
}

- (void)playPressed
{
    if (_mediaIsAvailable)
    {
        if (_status != nil && !_status.paused)
        {
            if (_context.pauseAudioMessage)
                _context.pauseAudioMessage();
            
            _playing = false;
        }
        else if (_status != nil && _status.paused)
        {
            if (_context.resumeAudioMessage)
                _context.resumeAudioMessage();
            
            _playing = true;
        }
        else
        {
            if (_context.playAudioMessageId)
                _context.playAudioMessageId(_mid);
            
            _playing = true;
        }
    }
}

- (void)unsentButtonTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
        [_context.companionHandle requestAction:@"showUnsentMessageMenu" options:@{@"mid": @(_mid)}];
}

- (void)replyHeaderTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (_replyHeaderModel != nil) {
            [_context.companionHandle requestAction:@"navigateToMessage" options:@{@"mid": @(_replyMessageId), @"sourceMid": @(_mid)}];
        }
    }
}

- (void)forwardHeaderTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (_forwardedHeaderModel != nil) {
            if (TGPeerIdIsChannel(_forwardedPeerId)) {
                [_context.companionHandle requestAction:@"peerAvatarTapped" options:@{@"peerId": @(_forwardedPeerId), @"messageId": @(_forwardedMessageId)}];
            } else {
                [_context.companionHandle requestAction:@"userAvatarTapped" options:@{@"uid": @((int32_t)_forwardedPeerId)}];
            }
        }
    }
}

- (void)messageTapGesture:(UITapGestureRecognizer *)recognizer
{
    UIView *view = recognizer.view;
    CGPoint center = CGPointMake(view.bounds.size.width / 2.0f, view.bounds.size.height / 2.0f);
    CGFloat radius = view.bounds.size.width / 2.0f;
    CGPoint point = [recognizer locationInView:recognizer.view];
    
    if (pow(point.x - center.x, 2) + pow(point.y - center.y, 2) < pow(radius, 2))
    {        
        if (recognizer.state == UIGestureRecognizerStateRecognized)
            [self playPressed];
    }
}

- (void)messageDoubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        if (recognizer.longTapped)
            [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
    }
}

- (bool)gestureRecognizerShouldHandleLongTap:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
    return true;
}

- (void)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer didBeginAtPoint:(CGPoint)__unused point
{
}

- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer shouldFailTap:(CGPoint)__unused point
{
    return 0;
}

- (void)doubleTapGestureRecognizerSingleTapped:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
}

- (bool)gestureRecognizerShouldLetScrollViewStealTouches:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
    return true;
}

- (bool)gestureRecognizerShouldFailOnMove:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
    return true;
}

- (void)messageImageViewActionButtonPressed:(TGMessageImageView *)messageImageView withAction:(TGMessageImageViewActionType)action
{
    if (messageImageView == ((TGMessageImageViewContainer *)[_imageModel boundView]).imageView)
    {
        if (action == TGMessageImageViewActionCancelDownload)
            [self cancelMediaDownload];
        else
            [self actionButtonPressed];
    }
}

- (void)actionButtonPressed
{
    if (_mediaIsAvailable)
        [self playPressed];
    else
        [_context.companionHandle requestAction:@"mediaDownloadRequested" options:@{@"mid": @(_mid)}];
}

- (void)deactivateMedia:(bool)instant
{
    [_context.companionHandle requestAction:@"closeMediaRequested" options:@{@"mid": @(_mid), @"instant": @(instant)}];
}

- (void)cancelMediaDownload
{
    [_context.companionHandle requestAction:@"mediaProgressCancelRequested" options:@{@"mid": @(_mid)}];
}

- (void)setForwardHeader:(id)forwardPeer forwardAuthor:(id)forwardAuthor messageId:(int32_t)messageId
{
    if (_forwardedHeaderModel == nil)
    {
        static NSRange formatNameRange;
        
        static int localizationVersion = -1;
        if (localizationVersion != TGLocalizedStaticVersion)
            formatNameRange = [TGLocalized(@"Message.ForwardedMessageShort") rangeOfString:@"%@"];
        
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
        }
        
        NSMutableArray *additionalAttributes = [[NSMutableArray alloc] init];
        NSMutableArray *textCheckingResults = [[NSMutableArray alloc] init];
        
        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageForwardNameFont], (NSString *)kCTFontAttributeName, nil];
        
        NSString *text = [[NSString alloc] initWithFormat:TGLocalized(@"Message.ForwardedMessageShort"), authorName];
        
        _forwardedHeaderModel = [[TGModernTextViewModel alloc] initWithText:text font:[[TGTelegraphConversationMessageAssetsSource instance] messageForwardTitleFont]];
        _forwardedHeaderModel.textColor = [UIColor whiteColor];
        _forwardedHeaderModel.maxNumberOfLines = 2;
        _forwardedHeaderModel.layoutFlags = TGReusableLabelLayoutMultiline;
        if (formatNameRange.location != NSNotFound && authorName.length != 0)
        {
            NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
            [additionalAttributes addObjectsFromArray:@[[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes]];
        }
        
        _forwardedHeaderModel.additionalAttributes = additionalAttributes;
        _forwardedHeaderModel.textCheckingResults = textCheckingResults;
    }
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    bool isPost = _authorPeer != nil && [_authorPeer isKindOfClass:[TGConversation class]];
    TGMessageViewModelLayoutConstants const *layoutConstants = TGGetMessageViewModelLayoutConstants();
    
    CGFloat topSpacing = (_collapseFlags & TGModernConversationItemCollapseTop) ? layoutConstants->topInsetCollapsed : layoutConstants->topInset;
    CGFloat bottomSpacing = (_collapseFlags & TGModernConversationItemCollapseBottom) ? layoutConstants->bottomInsetCollapsed : layoutConstants->bottomInset;
    
    if (isPost) {
        topSpacing = layoutConstants->topPostInset;
        bottomSpacing = layoutConstants->bottomPostInset;
    }
    
    bottomSpacing += 3.0f;
    
    CGFloat avatarOffset = 0.0f;
    if (_hasAvatar)
        avatarOffset = 35.0f;
    
    CGFloat unsentOffset = 0.0f;
    if (!_incomingAppearance && _deliveryState == TGMessageDeliveryStateFailed)
        unsentOffset = 29.0f;
    
    CGSize size = [TGRoundMessageViewModel roundSize];
    CGRect backgroundFrame = CGRectMake(_incomingAppearance ? (avatarOffset + layoutConstants->leftImageInset) : (containerSize.width - size.width - layoutConstants->rightImageInset - unsentOffset), topSpacing, size.width, size.height);;
    if (_incomingAppearance && _editing)
        backgroundFrame.origin.x += 42.0f;
    
    _backgroundModel.frame = backgroundFrame;
    CGFloat inset = 2.0f;
    if (TGScreenScaling() == 2.0f)
        inset = 2.5f;
    else if (TGScreenScaling() == 1.0f)
        inset = 3.5f;
    
    _imageModel.frame = CGRectInset(backgroundFrame, inset, inset);
    _ringModel.frame = _imageModel.frame;
    
    CGFloat pixel = MIN(0.5f, TGScreenPixel);
    _muteButtonModel.frame = CGRectMake(floor(CGRectGetMidX(backgroundFrame) - 12.0f), CGRectGetMaxY(backgroundFrame) - 24.0f - 8.0f - pixel, 24.0f, 24.0f);
    
    if (_contentModel != nil)
    {
        CGFloat availableWidth = containerSize.width - backgroundFrame.size.width - 13.0f - avatarOffset;
        
        bool updateContent = false;
        CGRect contentFrame = CGRectZero;
        
        if (_replyHeaderModel != nil)
        {
            [_replyHeaderModel layoutForContainerSize:CGSizeMake(availableWidth, 0.0f) updateContent:&updateContent];
            contentFrame = CGRectMake(0.0f, 0.0f, _replyHeaderModel.frame.size.width + 17.0f, _replyHeaderModel.frame.size.height + 5.0f);
        }
        else if (_forwardedHeaderModel != nil)
        {
            [_forwardedHeaderModel layoutForContainerSize:CGSizeMake(availableWidth, 0.0f)];
            contentFrame = CGRectMake(0.0f, 0.0f, _forwardedHeaderModel.frame.size.width + 16.0f, _forwardedHeaderModel.frame.size.height + 11.0f);
        }

        if (_incomingAppearance)
            contentFrame.origin.x = containerSize.width - contentFrame.size.width - 7.0f;
        else
            contentFrame.origin.x = 9.0f + (_editing ? 42.0f : 0.0f);
        
        contentFrame.origin.y = 0.0f; //floor(CGRectGetMidY(backgroundFrame) - contentFrame.size.height / 2.0f);
        
        _contentModel.frame = contentFrame;
        if (_replyHeaderModel != nil)
        {
            _replyHeaderModel.frame = CGRectMake(7.0f, _replyHeaderViaUserModel == nil ? 0.0f : (_replyHeaderViaUserModel.frame.size.height + 2.0), _replyHeaderModel.frame.size.width, _replyHeaderModel.frame.size.height);
        }
        else if (_forwardedHeaderModel != nil)
        {
            _forwardedHeaderModel.frame = CGRectMake(7.0f, 4.0f, _forwardedHeaderModel.frame.size.width, _forwardedHeaderModel.frame.size.height);
        }
        _headerBackgroundModel.frame = CGRectMake(contentFrame.origin.x, contentFrame.origin.y + 3.0f, contentFrame.size.width - 2.0f, contentFrame.size.height - 5.0f);
        
        if ((!_incomingAppearance && CGRectGetMaxX(_headerBackgroundModel.frame) > backgroundFrame.origin.x + 22.0f) || _headerBackgroundModel.frame.size.width < 70.0f)
        {
            _contentModel.alpha = 0.0f;
            _headerBackgroundModel.alpha = 0.0f;
        }
        else
        {
            _contentModel.alpha = 1.0f;
            _headerBackgroundModel.alpha = 1.0f;
            
            if (_forwardedHeaderModel != nil)
                updateContent = true;
        }
        
        if (updateContent)
        {
            [_contentModel setNeedsSubmodelContentsUpdate];
            [_contentModel updateSubmodelContentsIfNeeded];
        }
    }
    
    if (_unsentButtonModel != nil)
    {
        _unsentButtonModel.frame = CGRectMake(containerSize.width - _unsentButtonModel.frame.size.width - 9, _imageModel.frame.size.height + topSpacing + bottomSpacing - _unsentButtonModel.frame.size.height - ((_collapseFlags & TGModernConversationItemCollapseBottom) ? 5 : 6), _unsentButtonModel.frame.size.width, _unsentButtonModel.frame.size.height);
    }
    
    if (_shareButtonModel != nil) {
        _shareButtonModel.frame = CGRectOffset(_shareButtonModel.bounds, CGRectGetMaxX(_backgroundModel.frame) - 8.0f, CGRectGetMaxY(_backgroundModel.frame) - 30.0f - 26.0f);
    }
    
    CGFloat replyButtonsHeight = 0.0f;
    if (_replyButtonsModel != nil) {
        CGRect backgroundFrame = _imageModel.frame;
        
        [_replyButtonsModel layoutForContainerSize:CGSizeMake(MIN(MAX([_replyButtonsModel minimumWidth], backgroundFrame.size.width + 10.0f), containerSize.width - 38.0f), containerSize.height)];
        
        _replyButtonsModel.frame = CGRectMake((_incomingAppearance ? backgroundFrame.origin.x : (CGRectGetMaxX(backgroundFrame) - _replyButtonsModel.frame.size.width)) + (_incomingAppearance ? -5.0f : 5.0f), CGRectGetMaxY(backgroundFrame), _replyButtonsModel.frame.size.width, _replyButtonsModel.frame.size.height);
        replyButtonsHeight = _replyButtonsModel.frame.size.height;
        self.avatarOffset = 2.0f + replyButtonsHeight;
    }
    else
    {
        self.avatarOffset = 2.0f;
    }
    
    CGRect frame = self.frame;
    frame.size = CGSizeMake(containerSize.width, size.height + topSpacing + bottomSpacing + replyButtonsHeight);
    self.frame = frame;
    
    [super layoutForContainerSize:containerSize];
}

@end
