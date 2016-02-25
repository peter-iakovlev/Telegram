#import "TGImageMessageViewModel.h"

#import "TGImageMediaAttachment.h"
#import "TGUser.h"
#import "TGConversation.h"
#import "TGMessage.h"
#import "TGPeerIdAdapter.h"

#import "TGImageUtils.h"
#import "TGDateUtils.h"
#import "TGStringUtils.h"
#import "TGFont.h"

#import "TGModernConversationItem.h"

#import "TGModernView.h"

#import "TGTelegraphConversationMessageAssetsSource.h"
#import "TGDoubleTapGestureRecognizer.h"

#import "TGModernViewContext.h"

#import "TGMessageImageViewModel.h"
#import "TGModernImageViewModel.h"
#import "TGModernFlatteningViewModel.h"
#import "TGModernDateViewModel.h"
#import "TGModernClockProgressViewModel.h"
#import "TGModernButtonViewModel.h"

#import "TGModernRemoteImageView.h"

#import "TGMessageImageView.h"

#import "TGInstantPreviewTouchAreaModel.h"

#import "TGTimerTarget.h"

#import "TGContentBubbleViewModel.h"
#import "TGReplyHeaderModel.h"

#import "TGReusableLabel.h"

#import "TGTextMessageBackgroundViewModel.h"
#import "TGModernFlatteningViewModel.h"
#import "TGModernTextViewModel.h"

#import "TGContentBubbleViewModel.h"

#import "TGMessageViewsViewModel.h"
#import "TGModernButtonView.h"
#import "TGModernButtonViewModel.h"

#import "TGTextCheckingResult.h"

#import "TGViewController.h"

@interface TGImageMessageViewModel () <UIGestureRecognizerDelegate, TGDoubleTapGestureRecognizerDelegate, TGMessageImageViewDelegate>
{
    TGModernViewContext *_context;
    
    bool _incoming;
    bool _incomingAppearance;
    TGMessageDeliveryState _deliveryState;
    bool _read;
    int _date;
    int32_t _messageLifetime;
    
    NSString *_legacyThumbnailCacheUri;
    
    bool _hasAvatar;
    bool _isBot;
    
    float _progress;
    bool _progressVisible;
    
    bool _isMessageViewed;
    NSTimeInterval _messageViewDate;
    
    TGDoubleTapGestureRecognizer *_boundDoubleTapRecognizer;
    TGDoubleTapGestureRecognizer *_boundBackgroundDoubleTapRecognizer;
    
    TGModernTextViewModel *_textModel;
    NSArray *_currentLinkSelectionViews;
    
    TGModernDateViewModel *_dateModel;
    TGModernClockProgressViewModel *_progressModel;
    TGModernImageViewModel *_checkFirstModel;
    TGModernImageViewModel *_checkSecondModel;
    TGModernTextViewModel *_authorSignatureModel;
    NSString *_authorSignature;
    
    bool _checkFirstEmbeddedInContent;
    bool _checkSecondEmbeddedInContent;
    
    TGModernImageViewModel *_unsentButtonModel;
    UITapGestureRecognizer *_unsentButtonTapRecognizer;
    
    TGInstantPreviewTouchAreaModel *_instantPreviewTouchAreaModel;
    
    UIImageView *_temporaryHighlightView;
    
    CGPoint _boundOffset;
    
    NSTimer *_viewDateTimer;
    
    TGTextMessageBackgroundViewModel *_backgroundModel;
    TGModernTextViewModel *_forwardedHeaderModel;
    TGModernTextViewModel *_authorNameModel;
    TGModernTextViewModel *_viaUserModel;
    TGUser *_viaUser;
    TGReplyHeaderModel *_replyHeaderModel;
    
    int32_t _replyMessageId;
    int64_t _forwardedPeerId;
    int32_t _forwardedMessageId;
    
    NSString *_caption;
    TGMessageViewCountContentProperty *_messageViews;
    TGMessageViewsViewModel *_messageViewsModel;
    
    TGModernButtonViewModel *_shareButtonModel;
    
    TGMessage *_replyHeader;
    id _replyAuthor;
    id _forwardPeer;
    bool _isChannel;
    id _forwardAuthor;
    TGMessage *_message;
    NSArray *_textCheckingResults;
    UIColor *_authorNameColor;
}

@end

@implementation TGImageMessageViewModel

static CTFontRef textFontForSize(CGFloat size)
{
    static CTFontRef font = NULL;
    static int cachedSize = 0;
    
    if ((int)size != cachedSize || font == NULL)
    {
        font = TGCoreTextSystemFontOfSize(size);
        cachedSize = (int)size;
    }
    
    return font;
}

- (instancetype)initWithMessage:(TGMessage *)message imageInfo:(TGImageInfo *)imageInfo authorPeer:(id)authorPeer context:(TGModernViewContext *)context forwardPeer:(id)forwardPeer forwardAuthor:(id)forwardAuthor forwardMessageId:(int32_t)forwardMessageId replyHeader:(TGMessage *)replyHeader replyAuthor:(id)replyAuthor viaUser:(TGUser *)viaUser
{
    return [self initWithMessage:message imageInfo:imageInfo authorPeer:authorPeer context:context forwardPeer:forwardPeer forwardAuthor:forwardAuthor forwardMessageId:forwardMessageId replyHeader:replyHeader replyAuthor:replyAuthor viaUser:viaUser caption:nil textCheckingResults:nil];
}

- (instancetype)initWithMessage:(TGMessage *)message imageInfo:(TGImageInfo *)imageInfo authorPeer:(id)authorPeer context:(TGModernViewContext *)context forwardPeer:(id)forwardPeer forwardAuthor:(id)forwardAuthor forwardMessageId:(int32_t)forwardMessageId replyHeader:(TGMessage *)replyHeader replyAuthor:(id)replyAuthor viaUser:(TGUser *)viaUser caption:(NSString *)caption textCheckingResults:(NSArray *)textCheckingResults
{
    self = [super initWithAuthorPeer:authorPeer context:context];
    if (self != nil)
    {
        _previewEnabled = true;
        _canDownload = true;
        
        _context = context;
        
        bool isChannel = [authorPeer isKindOfClass:[TGConversation class]];
        
        _incoming = !message.outgoing;
        _incomingAppearance = _incoming || isChannel;
        _deliveryState = message.deliveryState;
        _read = !message.unread;
        _date = (int32_t)message.date;
        _messageViews = message.viewCount;
        _message = message;
        _textCheckingResults = textCheckingResults;
        
        if ([authorPeer isKindOfClass:[TGUser class]]) {
            TGUser *author = authorPeer;
            _isBot = author.kind == TGUserKindBot || author.kind == TGUserKindSmartBot;
        }
        
        _replyHeader = replyHeader;
        _replyAuthor = replyAuthor;
        _forwardPeer = forwardPeer;
        _viaUser = viaUser;
        _isChannel = isChannel;
        _caption = caption;
        _forwardedMessageId = forwardMessageId;
        _forwardAuthor = forwardAuthor;
        
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
        
        if (_replyHeader != nil || _caption.length != 0 || _forwardPeer != nil || _viaUser != nil) {
            imageUri = [imageUri stringByAppendingString:@"&flat=1"];
        }
        
        static UIColor *incomingDateColor = nil;
        static UIColor *outgoingDateColor = nil;
        
        static TGTelegraphConversationMessageAssetsSource *assetsSource = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            assetsSource = [TGTelegraphConversationMessageAssetsSource instance];
            
            incomingDateColor = UIColorRGBA(0x525252, 0.6f);
            outgoingDateColor = UIColorRGBA(0x008c09, 0.8f);
        });
        
        _hasAvatar = authorPeer != nil && ![authorPeer isKindOfClass:[TGConversation class]];
        
        static UIImage *placeholderImage = nil;
        static dispatch_once_t onceToken1;
        dispatch_once(&onceToken1, ^
        {
            placeholderImage = [[UIImage imageNamed:@"ModernMessageImagePlaceholder.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16];
        });
        
        _needsEditingCheckButton = true;
        
        _mid = message.mid;
        _deliveryState = message.deliveryState;
        _read = !message.unread;
        _date = (int32_t)message.date;
        _messageLifetime = message.messageLifetime;
        
        CGSize imageSize = CGSizeZero;
        _imageModel = [[TGMessageImageViewModel alloc] initWithUri:imageUri];
        
        CGSize imageOriginalSize = CGSizeMake(1, 1);
        [imageInfo imageUrlForLargestSize:&imageOriginalSize];
        imageSize = imageOriginalSize;
        
        _imageModel.skipDrawInContext = true;
        
        CGSize renderSize = CGSizeZero;
        [TGImageMessageViewModel calculateImageSizesForImageSize:imageSize thumbnailSize:&imageSize renderSize:&renderSize squareAspect:false hasCaption:_caption.length != 0];
        
        _imageModel.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        
        [self setupContentModel:nil];
        
        [self addSubmodel:_imageModel];
        
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
        
        bool isBot = false;
        if ([authorPeer isKindOfClass:[TGUser class]]) {
            if (((TGUser *)authorPeer).kind == TGUserKindBot || ((TGUser *)authorPeer).kind ==  TGUserKindSmartBot) {
                isBot = true;
            }
        }
        
        if (isChannel || _context.isBot || isBot) {
            [_backgroundModel setPartialMode:false];
            
            _shareButtonModel = [[TGModernButtonViewModel alloc] init];
            _shareButtonModel.image = [[TGTelegraphConversationMessageAssetsSource instance] systemShareButton];
            _shareButtonModel.modernHighlight = true;
            _shareButtonModel.frame = CGRectMake(0.0f, 0.0f, 29.0f, 29.0f);
            [self addSubmodel:_shareButtonModel];
        }
    }
    return self;
}

- (void)enableInstantPreview
{
    if (_instantPreviewTouchAreaModel == nil)
    {
        __weak TGImageMessageViewModel *weakSelf = self;
        _instantPreviewTouchAreaModel = [[TGInstantPreviewTouchAreaModel alloc] init];
        _instantPreviewTouchAreaModel.touchesBeganAction = ^
        {
            __strong TGImageMessageViewModel *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf activateMedia:true];
        };
        _instantPreviewTouchAreaModel.touchesCompletedAction = ^
        {
            __strong TGImageMessageViewModel *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf deactivateMedia:true];
        };
        
        _instantPreviewTouchAreaModel.viewUserInteractionDisabled = !_mediaIsAvailable || _progressVisible;
        
        [self addSubmodel:_instantPreviewTouchAreaModel];
    }
}

- (NSString *)stringForLifetime:(int32_t)remainingSeconds
{
    return [TGStringUtils stringForShortMessageTimerSeconds:remainingSeconds];
}

- (NSString *)defaultAdditionalDataString
{
    if (self.isSecret)
    {
        if (_isMessageViewed)
        {
            if (ABS(_messageViewDate - DBL_EPSILON) > 0.0)
            {
                NSTimeInterval endTime = _messageViewDate + _messageLifetime;
                int remainingSeconds = MAX(0, (int)(endTime - CFAbsoluteTimeGetCurrent()));
                return [self stringForLifetime:remainingSeconds];
            }
            return [self stringForLifetime:0];
        }
        else
            return [self stringForLifetime:_messageLifetime];
    }
    
    return nil;
}

- (void)setIsSecret:(bool)isSecret
{
    _isSecret = isSecret;
    
    [self updateImageOverlay:false];
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
    
    if (_backgroundModel != nil)
        imageUri = [imageUri stringByAppendingString:@"&flat=1"];

    [_imageModel setUri:imageUri];
}

- (void)setAuthorNameColor:(UIColor *)authorNameColor
{
    _authorNameModel.textColor = authorNameColor;
    _authorNameColor = authorNameColor;
}

- (void)setAuthorSignature:(NSString *)authorSignature {
    if (_caption.length != 0) {
        _authorSignatureModel.text = authorSignature;
    }
    _authorSignature = authorSignature;
    
    [_imageModel setTimestampString:[self timestampString] signatureString:_authorSignature displayCheckmarks:!_incoming && _deliveryState != TGMessageDeliveryStateFailed checkmarkValue:(_incoming ? 0 : ((_deliveryState == TGMessageDeliveryStateDelivered ? 1 : 0) + (_read ? 1 : 0))) displayViews:_messageViews != nil viewsValue:_messageViews.viewCount animated:false];
}

+ (void)calculateImageSizesForImageSize:(in CGSize)imageSize thumbnailSize:(out CGSize *)thumbnailSize renderSize:(out CGSize *)renderSize squareAspect:(bool)squareAspect
{
    [self calculateImageSizesForImageSize:imageSize thumbnailSize:thumbnailSize renderSize:renderSize squareAspect:squareAspect hasCaption:false];
}

+ (void)calculateImageSizesForImageSize:(in CGSize)imageSize thumbnailSize:(out CGSize *)thumbnailSize renderSize:(out CGSize *)renderSize squareAspect:(bool)squareAspect hasCaption:(bool)hasCaption
{
    if (squareAspect)
    {
        CGFloat squareSide = 180.0f;
        
        if (imageSize.width > imageSize.height)
        {
            if (renderSize)
                *renderSize = CGSizeMake(imageSize.width * squareSide / imageSize.height, squareSide);
        }
        else
        {
            if (renderSize)
                *renderSize = CGSizeMake(squareSide, imageSize.height * squareSide / imageSize.width);
        }
        
        if (thumbnailSize)
            *thumbnailSize = CGSizeMake(squareSide, squareSide);
        
        return;
    }
    
    CGFloat maxSide = false ? 312.0f : 246.0f;
    static bool hasLargeScreen = true;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hasLargeScreen = [TGViewController hasLargeScreen];
    });
    if (!hasLargeScreen) {
        maxSide -= 18.0f;
    }
    CGSize imageTargetMaxSize = CGSizeMake(maxSide, maxSide);
    CGSize imageScalingMaxSize = CGSizeMake(imageTargetMaxSize.width - 18.0f, imageTargetMaxSize.height - 18.0f);
    CGSize imageTargetMinSize = hasCaption ? CGSizeMake(128.0f, 128.f) : CGSizeMake(128.0f, 128.0f);
    
    CGFloat imageAspect = 1.0f;
    if (imageSize.width > 1.0f - FLT_EPSILON && imageSize.height > 1.0f - FLT_EPSILON)
        imageAspect = imageSize.width / imageSize.height;
    
    if (imageSize.width < imageScalingMaxSize.width || imageSize.height < imageScalingMaxSize.height)
    {
        if (imageSize.width <= FLT_EPSILON || imageSize.height <= FLT_EPSILON)
            imageSize = imageTargetMinSize;
    }
    else
    {
        if (imageSize.width > imageTargetMaxSize.width)
        {
            imageSize.width = imageTargetMaxSize.width;
            imageSize.height = CGFloor(imageTargetMaxSize.width / imageAspect);
        }
        
        if (imageSize.height > imageTargetMaxSize.height)
        {
            imageSize.width = CGFloor(imageTargetMaxSize.height * imageAspect);
            imageSize.height = imageTargetMaxSize.height;
        }
    }
    
    if (renderSize != NULL)
        *renderSize = imageSize;
    
    imageSize.width = MIN(imageTargetMaxSize.width, imageSize.width);
    imageSize.height = MIN(imageTargetMaxSize.height, imageSize.height);
    
    imageSize.width = MAX(imageTargetMinSize.width, imageSize.width);
    imageSize.height = MAX(imageTargetMinSize.height, imageSize.height);
    
    if (thumbnailSize != NULL)
        *thumbnailSize = imageSize;
}

- (UIImage *)dateBackground
{
    static UIImage *dateBackgroundImage = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dateBackgroundImage = [[UIImage imageNamed:@"ModernMessageImageDateBackground.png"] stretchableImageWithLeftCapWidth:9 topCapHeight:9];
    });
    
    return dateBackgroundImage;
}

- (UIColor *)dateColor
{
    return [UIColor whiteColor];
}

- (UIImage *)checkPartialImage
{
    static UIImage *checkPartialImage = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        checkPartialImage = [UIImage imageNamed:@"ModernMessageCheckmarkMedia2.png"];
    });
    
    return checkPartialImage;
}

- (UIImage *)checkCompleteImage
{
    static UIImage *checkCompleteImage = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        checkCompleteImage = [UIImage imageNamed:@"ModernMessageCheckmarkMedia1.png"];
    });
    
    return checkCompleteImage;
}

- (int)clockProgressType
{
    return TGModernClockProgressTypeOutgoingMediaClock;
}

- (CGPoint)dateOffset
{
    return CGPointZero;
}

- (bool)instantPreviewGesture
{
    return false;
}

- (void)setTemporaryHighlighted:(bool)temporaryHighlighted viewStorage:(TGModernViewStorage *)__unused viewStorage
{
    if (_backgroundModel != nil)
    {
        if (temporaryHighlighted)
            [_backgroundModel setHighlightedIfBound];
        else
            [_backgroundModel clearHighlight];
    }
    else
    {
        if ([_imageModel boundView] != nil)
        {
            if (temporaryHighlighted)
            {
                if (_temporaryHighlightView == nil)
                {
                    UIImage *highlightImage = [UIImage imageNamed:@"ModernImageBubbleHighlight.png"];
                    _temporaryHighlightView = [[UIImageView alloc] initWithImage:[highlightImage stretchableImageWithLeftCapWidth:(int)(highlightImage.size.width / 2.0f) topCapHeight:(int)(highlightImage.size.height / 2.0f)]];
                    _temporaryHighlightView.frame = [_imageModel boundView].frame;
                    [[_imageModel boundView].superview addSubview:_temporaryHighlightView];
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

- (void)updateMediaAvailability:(bool)mediaIsAvailable viewStorage:(TGModernViewStorage *)__unused viewStorage delayDisplay:(bool)delayDisplay
{
    _mediaIsAvailable = mediaIsAvailable;
    
    if (mediaIsAvailable || !delayDisplay) {
        [self updateImageOverlay:false];
    }
}

- (void)updateMediaVisibility
{
    _imageModel.mediaVisible = [_context isMediaVisibleInMessage:_mid];
}

- (NSString *)timestampString {
    NSString *dateText = nil;
    if (debugShowMessageIds)
        dateText = [[NSString alloc] initWithFormat:@"%d", _mid];
    else
        dateText = [TGDateUtils stringForShortTime:_date];
    return dateText;
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated
{
    [super updateMessage:message viewStorage:viewStorage sizeUpdated:sizeUpdated];
    
    NSString *previousCaption = _caption;
    NSString *currentCaption = nil;
    NSArray *currentTextCheckingResults = nil;
    
    for (id attachment in message.mediaAttachments) {
        if ([attachment isKindOfClass:[TGImageMediaAttachment class]]) {
            currentCaption = ((TGImageMediaAttachment *)attachment).caption;
            currentTextCheckingResults = ((TGImageMediaAttachment *)attachment).textCheckingResults;
        } else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]]) {
            currentCaption = ((TGVideoMediaAttachment *)attachment).caption;
            currentTextCheckingResults = ((TGVideoMediaAttachment *)attachment).textCheckingResults;
        }
    }
    
    if (!TGStringCompare(previousCaption, currentCaption)) {
        _caption = currentCaption;
        _textCheckingResults = currentTextCheckingResults;
        
        bool rebind = false;
        
        if (previousCaption.length == 0 && currentCaption.length != 0) {
            rebind = true;
        } else if (previousCaption.length != 0 && currentCaption.length == 0) {
            rebind = true;
        } else {
            _textModel.text = _caption;
            _textModel.textCheckingResults = currentTextCheckingResults;
            [_contentModel setNeedsSubmodelContentsUpdate];
        }
        
        *sizeUpdated = true;
        
        if (rebind) {
            UIView *container = _imageModel.boundView.superview;
            [self unbindView:viewStorage];
            
            [self setupContentModel:viewStorage];
            
            [self bindViewToContainer:container viewStorage:viewStorage];
            
            [_contentModel setNeedsSubmodelContentsUpdate];
            [_contentModel updateSubmodelContentsIfNeeded];
        }
    }
    
    _mid = message.mid;
    
    if (_deliveryState != message.deliveryState || (!_incoming && _read != !message.unread) || (_messageViews != nil && _messageViews.viewCount != message.viewCount.viewCount))
    {
        _messageViews = message.viewCount;
        TGMessageViewModelLayoutConstants const *layoutConstants = TGGetMessageViewModelLayoutConstants();
        
        TGMessageDeliveryState previousDeliveryState = _deliveryState;
        _deliveryState = message.deliveryState;
        
        if (_messageViewsModel != nil) {
            _messageViewsModel.count = message.viewCount.viewCount;
            _messageViewsModel.hidden = _deliveryState != TGMessageDeliveryStateDelivered;
        }
        
        bool previousRead = _read;
        _read = !message.unread;
        
        if (_caption.length == 0)
        {
            [_imageModel setTimestampString:[self timestampString] signatureString:_authorSignature displayCheckmarks:!_incoming && _deliveryState != TGMessageDeliveryStateFailed checkmarkValue:(_incoming ? 0 : ((_deliveryState == TGMessageDeliveryStateDelivered ? 1 : 0) + (_read ? 1 : 0))) displayViews:_messageViews != nil viewsValue:_messageViews.viewCount animated:true];
            [_imageModel setDisplayTimestampProgress:_deliveryState == TGMessageDeliveryStatePending];
        }
        else
        {
            if (_date != (int32_t)message.date && !debugShowMessageIds)
            {
                _date = (int32_t)message.date;
                
                int daytimeVariant = 0;
                NSString *dateText = [TGDateUtils stringForShortTime:(int)message.date daytimeVariant:&daytimeVariant];
                [_dateModel setText:dateText daytimeVariant:daytimeVariant];
            }
        }
        
        if (_deliveryState == TGMessageDeliveryStateDelivered)
        {
            if (_caption.length > 0)
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
            }
            
            if (_unsentButtonModel != nil)
            {
                [self removeSubmodel:_unsentButtonModel viewStorage:viewStorage];
                _unsentButtonModel = nil;
            }
        }
        else if (_deliveryState == TGMessageDeliveryStateFailed)
        {
            if (_caption.length > 0)
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
            }
            
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
            if (_caption.length > 0)
            {
                if (_progressModel == nil)
                {
                    CGFloat unsentOffset = 0.0f;
                    if (!_incoming && previousDeliveryState == TGMessageDeliveryStateFailed)
                        unsentOffset = 29.0f;
                    
                    _progressModel = [[TGModernClockProgressViewModel alloc] initWithType:TGModernClockProgressTypeOutgoingClock];
                    _progressModel.frame = CGRectMake(self.frame.size.width - 28 - layoutConstants->rightInset - unsentOffset, _contentModel.frame.origin.y + _contentModel.frame.size.height - 17 + 1.0f, 15, 15);
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
                
                if (![self containsSubmodel:_checkFirstModel] && !_incomingAppearance)
                {
                    [self addSubmodel:_checkFirstModel];
                    
                    if ([_contentModel boundView] != nil)
                        [_checkFirstModel bindViewToContainer:[_contentModel boundView].superview viewStorage:viewStorage];
                }
                if (![self containsSubmodel:_checkSecondModel] && !_incomingAppearance)
                {
                    [self addSubmodel:_checkSecondModel];
                    
                    if ([_contentModel boundView] != nil)
                        [_checkSecondModel bindViewToContainer:[_contentModel boundView].superview viewStorage:viewStorage];
                }
                
                _checkFirstModel.alpha = 0.0f;
                _checkSecondModel.alpha = 0.0f;
            }
            
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
}

- (void)_maybeRestructureStateModels:(TGModernViewStorage *)viewStorage
{
    if (!_incoming && [_contentModel boundView] == nil && !_incomingAppearance)
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

- (void)updateProgress:(bool)progressVisible progress:(float)progress viewStorage:(TGModernViewStorage *)__unused viewStorage animated:(bool)animated
{
    [super updateProgress:progressVisible progress:progress viewStorage:viewStorage animated:animated];
    
    bool progressWasVisible = _progressVisible;
    float previousProgress = _progress;
    
    _progress = progress;
    _progressVisible = progressVisible;
    
    [self updateImageOverlay:((progressWasVisible && !_progressVisible) || (_progressVisible && ABS(_progress - previousProgress) > FLT_EPSILON)) && animated];
}

- (void)updateMessageAttributes
{
    [super updateMessageAttributes];
    
    if (self.isSecret)
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
        [_imageModel setAdditionalDataString:[self defaultAdditionalDataString]];
        [self updateImageOverlay:true];
        
        _viewDateTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(_updateViewDateTimerIfVisible) interval:0.5 repeat:false runLoopModes:NSRunLoopCommonModes];
    }
}

- (void)_invalidateViewDateTimer
{
    [_viewDateTimer invalidate];
    _viewDateTimer = nil;
}

- (void)updateImageOverlay:(bool)animated
{
    _instantPreviewTouchAreaModel.viewUserInteractionDisabled = !_mediaIsAvailable || _progressVisible;
    
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
        if (self.isSecret && _isMessageViewed && _incoming && ABS(_messageViewDate) > DBL_EPSILON)
        {
            NSTimeInterval endTime = _messageViewDate + _messageLifetime;
            int remainingSeconds = MAX(0, (int)(endTime - CFAbsoluteTimeGetCurrent()));
            
            [_imageModel setSecretProgress:(CGFloat)remainingSeconds / (CGFloat)_messageLifetime completeDuration:_messageLifetime animated:animated];
            [_imageModel setOverlayType:TGMessageImageViewOverlaySecretProgress];
        }
        else
            [_imageModel setOverlayType:[self defaultOverlayActionType] animated:animated];
    }
}

- (void)imageDataInvalidated:(NSString *)imageUrl
{
    if ([_legacyThumbnailCacheUri isEqualToString:imageUrl])
    {
        [_imageModel reloadImage:false];
    }
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    _boundOffset = itemPosition;
    
    [_backgroundModel bindViewToContainer:container viewStorage:viewStorage];
    [_backgroundModel boundView].frame = CGRectOffset([_backgroundModel boundView].frame, itemPosition.x, itemPosition.y);
    
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
    
    [_imageModel bindViewToContainer:container viewStorage:viewStorage];
    [_imageModel boundView].frame = CGRectOffset([_imageModel boundView].frame, itemPosition.x, itemPosition.y);
    ((TGMessageImageViewContainer *)[_imageModel boundView]).imageView.delegate = self;
    
    [_replyHeaderModel bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:CGPointMake(itemPosition.x + _contentModel.frame.origin.x + _replyHeaderModel.frame.origin.x, itemPosition.y + _contentModel.frame.origin.y + _replyHeaderModel.frame.origin.y)];
}

- (CGRect)effectiveContentFrame
{
    if (_backgroundModel != nil)
        return _backgroundModel.frame;
    
    return _imageModel.frame;
}

- (UIView *)referenceViewForImageTransition
{
    return [_imageModel boundView];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    _boundOffset = CGPointZero;
    
    [self _maybeRestructureStateModels:viewStorage];
    
    [self updateEditingState:nil viewStorage:nil animationDelay:-1.0];
    
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    [_replyHeaderModel bindSpecialViewsToContainer:_contentModel.boundView viewStorage:viewStorage atItemPosition:CGPointMake(_replyHeaderModel.frame.origin.x, _replyHeaderModel.frame.origin.y)];
    
    _boundDoubleTapRecognizer = [[TGDoubleTapGestureRecognizer alloc] initWithTarget:self action:@selector(messageDoubleTapGesture:)];
    _boundDoubleTapRecognizer.delegate = self;
    [[_imageModel boundView] addGestureRecognizer:_boundDoubleTapRecognizer];
    
    if (_backgroundModel != nil)
    {
        _boundBackgroundDoubleTapRecognizer = [[TGDoubleTapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundDoubleTapGesture:)];
        _boundBackgroundDoubleTapRecognizer.delegate = self;
        [[_backgroundModel boundView] addGestureRecognizer:_boundBackgroundDoubleTapRecognizer];
    }
    
    if (_unsentButtonModel != nil)
    {
        _unsentButtonTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unsentButtonTapGesture:)];
        [[_unsentButtonModel boundView] addGestureRecognizer:_unsentButtonTapRecognizer];
    }
    
    _imageModel.mediaVisible = [_context isMediaVisibleInMessage:_mid];
    
    ((TGMessageImageViewContainer *)[_imageModel boundView]).imageView.delegate = self;
    
    [self _updateViewDateTimerIfVisible];
    
    if (_shareButtonModel != nil) {
        [(TGModernButtonView *)_shareButtonModel.boundView addTarget:self action:@selector(sharePressed) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    [self clearLinkSelection];
    
    _boundOffset = CGPointZero;
    
    [[_imageModel boundView] removeGestureRecognizer:_boundDoubleTapRecognizer];
    _boundDoubleTapRecognizer.delegate = nil;
    _boundDoubleTapRecognizer = nil;
    
    ((TGMessageImageViewContainer *)[_imageModel boundView]).imageView.delegate = self;
    
    if (_backgroundModel != nil)
    {
        [[_backgroundModel boundView] removeGestureRecognizer:_boundBackgroundDoubleTapRecognizer];
        _boundBackgroundDoubleTapRecognizer.delegate = nil;
        _boundBackgroundDoubleTapRecognizer = nil;
    }
    
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
    
    [self _invalidateViewDateTimer];
    
    if (_shareButtonModel != nil)
    {
        [(TGModernButtonView *)_shareButtonModel.boundView removeTarget:self action:@selector(sharePressed) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [super unbindView:viewStorage];
}

- (void)messageDoubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan)
    {
        [self clearLinkSelection];
    }
    
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        if ([self instantPreviewGesture])
        {
            [_context.companionHandle requestAction:@"closeMediaRequested" options:@{@"mid": @(_mid)}];
        }
        else
        {
            if (recognizer.longTapped)
            {
                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
            }
            else
            {
                if (_mediaIsAvailable)
                {
                    [self activateMedia];
                }
                else
                    [_context.companionHandle requestAction:@"mediaDownloadRequested" options:@{@"mid": @(_mid)}];
            }
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateCancelled)
    {
        [_context.companionHandle requestAction:@"closeMediaRequested" options:@{@"mid": @(_mid)}];
    }
}

- (void)backgroundDoubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan)
    {
        [self clearLinkSelection];
    }
    
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint point = [recognizer locationInView:[_contentModel boundView]];
        NSString *linkCandidate = [_textModel linkAtPoint:CGPointMake(point.x - _textModel.frame.origin.x, point.y - _textModel.frame.origin.y) regionData:NULL];
        
        if (recognizer.longTapped)
        {
            if (linkCandidate != nil)
                [_context.companionHandle requestAction:@"openLinkWithOptionsRequested" options:@{@"url": linkCandidate}];
            else
                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
        }
        else if (recognizer.doubleTapped)
            [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
        else if (linkCandidate != nil)
            [_context.companionHandle requestAction:@"openLinkRequested" options:@{@"url": linkCandidate, @"mid": @(_mid)}];
        else if (_replyHeaderModel && CGRectContainsPoint(_replyHeaderModel.frame, point))
            [_context.companionHandle requestAction:@"navigateToMessage" options:@{@"mid": @(_replyMessageId), @"sourceMid": @(_mid)}];
        else if (_viaUserModel != nil && CGRectContainsPoint(_viaUserModel.frame, point)) {
            [_context.companionHandle requestAction:@"useContextBot" options:@{@"uid": @((int32_t)_viaUser.uid), @"username": _viaUser.userName == nil ? @"" : _viaUser.userName}];
        }
        else if (_forwardedHeaderModel && CGRectContainsPoint(_forwardedHeaderModel.frame, point)) {
            if (_viaUser != nil && [_forwardedHeaderModel linkAtPoint:CGPointMake(point.x - _forwardedHeaderModel.frame.origin.x, point.y - _forwardedHeaderModel.frame.origin.y) regionData:NULL]) {
                [_context.companionHandle requestAction:@"useContextBot" options:@{@"uid": @((int32_t)_viaUser.uid), @"username": _viaUser.userName == nil ? @"" : _viaUser.userName}];
            } else {
                if (TGPeerIdIsChannel(_forwardedPeerId)) {
                    [_context.companionHandle requestAction:@"peerAvatarTapped" options:@{@"peerId": @(_forwardedPeerId), @"messageId": @(_forwardedMessageId)}];
                } else {
                    [_context.companionHandle requestAction:@"userAvatarTapped" options:@{@"uid": @((int32_t)_forwardedPeerId)}];
                }
            }
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *imageView = ((TGMessageImageViewContainer *)[_imageModel boundView]).imageView;
    if (imageView != nil)
    {
        UIView *hitTestResult = [imageView hitTest:[gestureRecognizer locationInView:imageView] withEvent:nil];
        if ([hitTestResult isKindOfClass:[UIControl class]])
            return false;
        
        return true;
    }
    
    return false;
}

- (void)unsentButtonTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [_context.companionHandle requestAction:@"showUnsentMessageMenu" options:@{@"mid": @(_mid)}];
    }
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
    {
        if (![self instantPreviewGesture])
        {
            [self activateMedia];
        }
    }
    else
        [_context.companionHandle requestAction:@"mediaDownloadRequested" options:@{@"mid": @(_mid)}];
}

- (void)activateMedia
{
    [self activateMedia:false];
}

- (void)activateMedia:(bool)instant
{
    if (_previewEnabled)
        [_context.companionHandle requestAction:@"openMediaRequested" options:@{@"mid": @(_mid), @"instant": @(instant)}];
}

- (void)deactivateMedia:(bool)instant
{
    [_context.companionHandle requestAction:@"closeMediaRequested" options:@{@"mid": @(_mid), @"instant": @(instant)}];
}

- (void)cancelMediaDownload
{
    [_context.companionHandle requestAction:@"mediaProgressCancelRequested" options:@{@"mid": @(_mid)}];
}

- (bool)gestureRecognizerShouldHandleLongTap:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer == _boundDoubleTapRecognizer)
        return ![self instantPreviewGesture];
    
    return true;
}

- (void)gestureRecognizer:(TGDoubleTapGestureRecognizer *)recognizer didBeginAtPoint:(CGPoint)point
{
    if (recognizer == _boundBackgroundDoubleTapRecognizer)
        [self updateLinkSelection:point];
}

- (void)gestureRecognizerDidFail:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
    [self clearLinkSelection];
}

- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)recognizer shouldFailTap:(CGPoint)__unused point
{
    if (recognizer == _boundDoubleTapRecognizer)
        return 3;
    
    if (recognizer == _boundBackgroundDoubleTapRecognizer)
    {
        CGPoint convertedPoint = [recognizer locationInView:[_contentModel boundView]];
        if (([_textModel linkAtPoint:CGPointMake(convertedPoint.x - _textModel.frame.origin.x, convertedPoint.y - _textModel.frame.origin.y) regionData:NULL] != nil || (_replyHeaderModel && CGRectContainsPoint(_replyHeaderModel.frame, convertedPoint)) || (_forwardedHeaderModel && CGRectContainsPoint(_forwardedHeaderModel.frame, convertedPoint)) ||
             (_viaUserModel && CGRectContainsPoint(_viaUserModel.frame, convertedPoint))))
            return 3;
    }

    return 0;
}

- (void)doubleTapGestureRecognizerSingleTapped:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
}

- (bool)gestureRecognizerShouldLetScrollViewStealTouches:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
    return true;
}

- (bool)gestureRecognizerShouldFailOnMove:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer == _boundDoubleTapRecognizer)
        return ![self instantPreviewGesture];
        
    return true;
}

- (void)setCollapseFlags:(int)collapseFlags
{
    if (_collapseFlags != collapseFlags)
    {
        _collapseFlags = collapseFlags;
        if (!(collapseFlags & TGModernConversationItemCollapseBottom) && [_authorPeer isKindOfClass:[TGConversation class]]) {
            [_backgroundModel setPartialMode:false];
        } else {
            [_backgroundModel setPartialMode:collapseFlags & TGModernConversationItemCollapseBottom];
        }
    }
}

- (CGSize)contentSizeForContainerSize:(CGSize)containerSize needsContentsUpdate:(bool *)needsContentsUpdate hasDate:(bool)hasDate hasViews:(bool)hasViews
{
    int layoutFlags = TGReusableLabelLayoutMultiline | TGReusableLabelLayoutHighlightLinks;
    if (hasDate) {
        layoutFlags |= TGReusableLabelLayoutDateSpacing | (_incoming ? 0 : TGReusableLabelLayoutExtendedDateSpacing);
    }
    if (hasViews) {
        layoutFlags |= TGReusableLabelViewCountSpacing;
    }
    
    if (_context.commandsEnabled || _isBot)
        layoutFlags |= TGReusableLabelLayoutHighlightCommands;
    
    bool updateContents = [_textModel layoutNeedsUpdatingForContainerSize:containerSize layoutFlags:layoutFlags];
    _textModel.layoutFlags = layoutFlags;
    if (updateContents)
        [_textModel layoutForContainerSize:containerSize];
    
    if (needsContentsUpdate != NULL)
        *needsContentsUpdate = updateContents;
    
    return _textModel.frame.size;
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
    
    CGSize headerSize = CGSizeZero;
    
    if (_replyHeaderModel != nil || _caption.length > 0 || _forwardedHeaderModel != nil || _viaUserModel != nil)
    {
        topSpacing += 3.0f - TGRetinaPixel;
        bottomSpacing += 6.0f;
        
        if (_authorNameModel != nil)
        {
            CGFloat maxWidth = _imageModel.frame.size.width - 11.0f;
            CGFloat maxNameWidth = _viaUserModel == nil ? maxWidth : (maxWidth - 40.0f);
            
            if (_authorNameModel.frame.size.width < FLT_EPSILON) {
                [_authorNameModel layoutForContainerSize:CGSizeMake(maxNameWidth, 0.0f)];
            }
            
            CGRect authorNameFrame = _authorNameModel.frame;
            authorNameFrame.origin = CGPointMake(3.0f, 1.0f + TGRetinaPixel);
            _authorNameModel.frame = authorNameFrame;
            
            headerSize = CGSizeMake(_authorNameModel.frame.size.width, _authorNameModel.frame.size.height + 1.0f);
            
            if (_viaUserModel != nil) {
                [_viaUserModel layoutForContainerSize:CGSizeMake(maxWidth - _authorNameModel.frame.size.width, 0.0f)];
                CGRect viaUserFrame = _viaUserModel.frame;
                viaUserFrame.origin = CGPointMake(CGRectGetMaxX(_authorNameModel.frame) + 4.0f, 1.0f + TGRetinaPixel);
                _viaUserModel.frame = viaUserFrame;
                
                headerSize.width += viaUserFrame.size.width + 4.0f;
            }
            
            if ((_replyHeaderModel == nil && _forwardedHeaderModel == nil)) {
                if (_caption.length > 0) {
                    headerSize.height += 7.0f;
                } else {
                    headerSize.height += 4.0f;
                }
            }
        } else if (_viaUserModel != nil) {
            [_viaUserModel layoutForContainerSize:CGSizeMake(320.0f - 80.0f - (_hasAvatar ? 38.0f : 0.0f), 0.0f)];
            
            CGRect viaUserFrame = _viaUserModel.frame;
            viaUserFrame.origin = CGPointMake(1.0f, 1.0f + TGRetinaPixel);
            _viaUserModel.frame = viaUserFrame;
            
            headerSize = CGSizeMake(_viaUserModel.frame.size.width, _viaUserModel.frame.size.height + 1.0f);
            
            if ((_replyHeaderModel == nil && _forwardedHeaderModel == nil)) {
                if (_caption.length > 0) {
                    headerSize.height += 7.0f;
                } else {
                    headerSize.height += 4.0f;
                }
            }
        }
        
        if (_forwardedHeaderModel != nil)
        {
            if (_forwardedHeaderModel.frame.size.width < FLT_EPSILON)
                [_forwardedHeaderModel layoutForContainerSize:CGSizeMake(_imageModel.frame.size.width - 11.0f, 0.0f)];
            
            CGRect forwardedHeaderFrame = _forwardedHeaderModel.frame;
            forwardedHeaderFrame.origin = CGPointMake(3.0f, (_authorNameModel != nil ? 2.0f : 1.0f) + headerSize.height);
            _forwardedHeaderModel.frame = forwardedHeaderFrame;
            
            headerSize.height += forwardedHeaderFrame.size.height + 6;
            headerSize.width = MAX(headerSize.width, forwardedHeaderFrame.size.width);
        }
        
        if (_replyHeaderModel != nil)
        {
            if (_replyHeaderModel.frame.size.width < FLT_EPSILON)
                [_replyHeaderModel layoutForContainerSize:CGSizeMake(_imageModel.frame.size.width - 11.0f, 0.0f)];
            
            CGRect replyHeaderFrame = _replyHeaderModel.frame;
            replyHeaderFrame.origin = CGPointMake(3.0f + TGRetinaPixel, headerSize.height + 1.0f);
            _replyHeaderModel.frame = replyHeaderFrame;
            
            headerSize.height += replyHeaderFrame.size.height + 6;
            headerSize.width = MAX(headerSize.width, replyHeaderFrame.size.width);
        }
    }
    
    CGFloat avatarOffset = 0.0f;
    if (_hasAvatar)
        avatarOffset = 38.0f;
    
    CGFloat unsentOffset = 0.0f;
    if (!_incoming && _deliveryState == TGMessageDeliveryStateFailed)
        unsentOffset = 29.0f;
    
    CGRect imageFrame = CGRectMake(_incomingAppearance ? (avatarOffset + layoutConstants->leftImageInset) : (containerSize.width - _imageModel.frame.size.width - layoutConstants->rightImageInset - unsentOffset), topSpacing + (isPost ? 2.0f : 0.0f), _imageModel.frame.size.width, _imageModel.frame.size.height);
    if (_incomingAppearance && _editing)
        imageFrame.origin.x += 42.0f;
    if (_replyHeaderModel != nil || _forwardedHeaderModel || _caption.length > 0 || _viaUserModel != nil)
    {
        if (_incomingAppearance)
            imageFrame.origin.x += 3.0f - TGRetinaPixel;
        else
            imageFrame.origin.x -= 3.0f - TGRetinaPixel;
        
        imageFrame.origin.y += headerSize.height;
    }
    _imageModel.frame = imageFrame;
    
    CGSize contentContainerSize = CGSizeMake(imageFrame.size.width, 0.0f);
    
    bool hasSignature = false;
    if (_authorSignature.length != 0) {
        hasSignature = true;
        [_authorSignatureModel layoutForContainerSize:CGSizeMake(contentContainerSize.width - 100.0f, CGFLOAT_MAX)];
    } else {
        _authorSignatureModel.frame = CGRectZero;
    }
    
    CGSize textSize = CGSizeZero;
    if (_textModel != nil)
    {
        bool updateContent = false;
        textSize = [self contentSizeForContainerSize:CGSizeMake(imageFrame.size.width - 12, containerSize.height) needsContentsUpdate:&updateContent hasDate:!hasSignature hasViews:!hasSignature && _messageViews != nil];
        textSize.height += 4 - TGRetinaPixel;
        
        CGRect textFrame = _textModel.frame;
        textFrame.origin = CGPointMake(3.0f, imageFrame.origin.y + imageFrame.size.height - 3.0f + TGRetinaPixel);
        
        if (_incomingAppearance)
        {
            textFrame.origin.y -=1;
            textSize.height -= 1;
        }
        
        if (hasSignature) {
            textSize.height += 14.0f;
        }
        
        _textModel.frame = textFrame;
    }
    
    _backgroundModel.frame = CGRectMake(imageFrame.origin.x - (_incomingAppearance ? 8.0f - TGRetinaPixel : 3.0f - TGRetinaPixel), topSpacing - (3.0f - TGRetinaPixel) + (isPost ? 2.0f : 0.0f), imageFrame.size.width + 11.0f - 2 * TGRetinaPixel, imageFrame.size.height + 4.0f - TGRetinaPixel + topSpacing + headerSize.height + textSize.height);
    
    if (_textModel == nil && (_replyHeaderModel != nil || _forwardedHeaderModel != nil || _viaUserModel != nil))
    {
        CGRect imageFrame = _imageModel.frame;
        imageFrame.origin.y = _backgroundModel.frame.origin.y + _backgroundModel.frame.size.height - _imageModel.frame.size.height - 3 + TGRetinaPixel;
        _imageModel.frame = imageFrame;
    }
    
    if (_backgroundModel == nil) {
        if (_shareButtonModel != nil) {
            _shareButtonModel.frame = CGRectOffset(_shareButtonModel.bounds, CGRectGetMaxX(_imageModel.frame) + 7.0f, CGRectGetMaxY(_imageModel.frame) - 29.0f - 1.0f);
        }
    } else {
        if (_shareButtonModel != nil) {
            _shareButtonModel.frame = CGRectOffset(_shareButtonModel.bounds, CGRectGetMaxX(_backgroundModel.frame) + 7.0f, CGRectGetMaxY(_backgroundModel.frame) - 29.0f - 1.0f);
        }
    }
    
    CGRect contentModelFrame = CGRectMake(imageFrame.origin.x + 3.0f + TGRetinaPixel, _backgroundModel.frame.origin.y + 2.0f, 0, 0);
    contentModelFrame.size = CGSizeMake(imageFrame.size.width + 1.0f, imageFrame.origin.y + imageFrame.size.height + 1.0f + TGRetinaPixel + textSize.height);
    _contentModel.frame = contentModelFrame;
    
    _instantPreviewTouchAreaModel.frame = imageFrame;
    
    if (_caption.length > 0)
    {
        _dateModel.frame = CGRectMake(_contentModel.frame.size.width - (_incomingAppearance ? 7 : 20.0f) - _dateModel.frame.size.width - 7.0f - TGRetinaPixel, _contentModel.frame.size.height - 21.0f - (TGIsLocaleArabic() ? 1.0f : 0.0f), _dateModel.frame.size.width, _dateModel.frame.size.height);
        
        CGFloat signatureSize = (hasSignature ? (_authorSignatureModel.frame.size.width + 8.0f) : 0.0f);
        
        if (_progressModel != nil) {
            if (_incomingAppearance) {
                _progressModel.frame = CGRectMake(CGRectGetMaxX(_backgroundModel.frame) - _dateModel.frame.size.width - 29 - unsentOffset - TGRetinaPixel - signatureSize, _contentModel.frame.origin.y + _contentModel.frame.size.height - 20 + 1.0f - TGRetinaPixel, 15, 15);
            } else {
                _progressModel.frame = CGRectMake(containerSize.width - 28 - layoutConstants->rightInset - unsentOffset - TGRetinaPixel - signatureSize, _contentModel.frame.origin.y + _contentModel.frame.size.height - 20 + 1.0f, 15, 15);
            }
        }
        
        if (_authorSignatureModel.text.length != 0) {
            _authorSignatureModel.frame = CGRectMake(CGRectGetMaxX(_backgroundModel.frame) - _dateModel.frame.size.width - 22.0f - (_incomingAppearance ? 0.0f : 14.0f) - _authorSignatureModel.frame.size.width - 12.0f - (TGIsPad() ? 12.0f : 0.0f), _contentModel.frame.origin.y + _contentModel.frame.size.height - 17 + 1.0f - 12.0f - (TGIsPad() ? 1.0f : 0.0f), _authorSignatureModel.frame.size.width, _authorSignatureModel.frame.size.height);
        } else {
            _authorSignatureModel.frame = CGRectZero;
        }
        
        CGPoint stateOffset = _contentModel.frame.origin;
        if (_checkFirstModel != nil)
            _checkFirstModel.frame = CGRectMake((_checkFirstEmbeddedInContent ? 0.0f : stateOffset.x) + _contentModel.frame.size.width - 17 - 7.0f - TGRetinaPixel, (_checkFirstEmbeddedInContent ? 0.0f : stateOffset.y) + _contentModel.frame.size.height - 17 + TGRetinaPixel, 12, 11);
        
        if (_checkSecondModel != nil)
            _checkSecondModel.frame = CGRectMake((_checkSecondEmbeddedInContent ? 0.0f : stateOffset.x) + _contentModel.frame.size.width - 13 - 7.0f - TGRetinaPixel, (_checkSecondEmbeddedInContent ? 0.0f : stateOffset.y) + _contentModel.frame.size.height - 17 + TGRetinaPixel, 12, 11);
        
        if (_messageViewsModel != nil) {
            _messageViewsModel.frame = CGRectMake(CGRectGetMaxX(_backgroundModel.frame) - _dateModel.frame.size.width - 22.0f - (_incomingAppearance ? 0.0f : 14.0f) - signatureSize, _dateModel.frame.origin.y + _contentModel.frame.origin.y + 2.0f + TGRetinaPixel, 1.0f, 1.0f);
        }
    }
    
    if (_unsentButtonModel != nil)
    {
        _unsentButtonModel.frame = CGRectMake(containerSize.width - _unsentButtonModel.frame.size.width - 9, _imageModel.frame.size.height + topSpacing + bottomSpacing + headerSize.height + textSize.height - _unsentButtonModel.frame.size.height - ((_collapseFlags & TGModernConversationItemCollapseBottom) ? 5 : 6), _unsentButtonModel.frame.size.width, _unsentButtonModel.frame.size.height);
    }
    
    CGRect frame = self.frame;
    frame.size = CGSizeMake(containerSize.width, _imageModel.frame.size.height + topSpacing + bottomSpacing + headerSize.height + textSize.height + 4.0f);
    self.frame = frame;
    
    [_contentModel updateSubmodelContentsIfNeeded];
    
    [super layoutForContainerSize:containerSize];
}

- (int)defaultOverlayActionType
{
    return _isSecret ? (_isMessageViewed ? TGMessageImageViewOverlaySecretViewed : TGMessageImageViewOverlaySecret) : TGMessageImageViewOverlayNone;
}

- (void)refreshMetrics
{
    if (_textModel != nil)
        [_textModel setFont:textFontForSize(TGGetMessageViewModelLayoutConstants()->textFontSize - 1)];
}

- (void)clearLinkSelection
{
    for (UIView *linkView in _currentLinkSelectionViews)
    {
        [linkView removeFromSuperview];
    }
    _currentLinkSelectionViews = nil;
}

- (void)updateLinkSelection:(CGPoint)point
{
    if ([_contentModel boundView] != nil)
    {
        [self clearLinkSelection];
        
        CGPoint offset = CGPointMake(_contentModel.frame.origin.x - _backgroundModel.frame.origin.x, _contentModel.frame.origin.y - _backgroundModel.frame.origin.y);
        
        NSArray *regionData = nil;
        NSString *link = [_textModel linkAtPoint:CGPointMake(point.x - _textModel.frame.origin.x - offset.x, point.y - _textModel.frame.origin.y - offset.y) regionData:&regionData];
        
        CGPoint regionOffset = CGPointZero;
        
        if (link != nil)
        {
            CGRect topRegion = regionData.count > 0 ? [regionData[0] CGRectValue] : CGRectZero;
            CGRect middleRegion = regionData.count > 1 ? [regionData[1] CGRectValue] : CGRectZero;
            CGRect bottomRegion = regionData.count > 2 ? [regionData[2] CGRectValue] : CGRectZero;
            
            topRegion.origin = CGPointMake(topRegion.origin.x + regionOffset.x, topRegion.origin.y + regionOffset.y);
            middleRegion.origin = CGPointMake(middleRegion.origin.x + regionOffset.x, middleRegion.origin.y + regionOffset.y);
            bottomRegion.origin = CGPointMake(bottomRegion.origin.x + regionOffset.x, bottomRegion.origin.y + regionOffset.y);
            
            UIImageView *topView = nil;
            UIImageView *middleView = nil;
            UIImageView *bottomView = nil;
            
            UIImageView *topCornerLeft = nil;
            UIImageView *topCornerRight = nil;
            UIImageView *bottomCornerLeft = nil;
            UIImageView *bottomCornerRight = nil;
            
            NSMutableArray *linkHighlightedViews = [[NSMutableArray alloc] init];
            
            topView = [[UIImageView alloc] init];
            middleView = [[UIImageView alloc] init];
            bottomView = [[UIImageView alloc] init];
            
            topCornerLeft = [[UIImageView alloc] init];
            topCornerRight = [[UIImageView alloc] init];
            bottomCornerLeft = [[UIImageView alloc] init];
            bottomCornerRight = [[UIImageView alloc] init];
            
            if (topRegion.size.height != 0)
            {
                topView.hidden = false;
                topView.frame = topRegion;
                if (middleRegion.size.height == 0 && bottomRegion.size.height == 0)
                    topView.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkFull];
                else
                    topView.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkFull];
            }
            else
            {
                topView.hidden = true;
                topView.frame = CGRectZero;
            }
            
            if (middleRegion.size.height != 0)
            {
                middleView.hidden = false;
                middleView.frame = middleRegion;
                if (bottomRegion.size.height == 0)
                    middleView.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkFull];
                else
                    middleView.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkFull];
            }
            else
            {
                middleView.hidden = true;
                middleView.frame = CGRectZero;
            }
            
            if (bottomRegion.size.height != 0)
            {
                bottomView.hidden = false;
                bottomView.frame = bottomRegion;
                bottomView.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkFull];
            }
            else
            {
                bottomView.hidden = true;
                bottomView.frame = CGRectZero;
            }
            
            topCornerLeft.hidden = true;
            topCornerRight.hidden = true;
            bottomCornerLeft.hidden = true;
            bottomCornerRight.hidden = true;
            
            if (topRegion.size.height != 0 && middleRegion.size.height != 0)
            {
                if (topRegion.origin.x == middleRegion.origin.x)
                {
                    topCornerLeft.hidden = false;
                    topCornerLeft.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkCornerLR];
                    topCornerLeft.frame = CGRectMake(topRegion.origin.x, topRegion.origin.y + topRegion.size.height - 3.5f, 4, 7);
                }
                else if (topRegion.origin.x < middleRegion.origin.x + middleRegion.size.width - 3.5f)
                {
                    topCornerLeft.hidden = false;
                    topCornerLeft.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkCornerBT];
                    topCornerLeft.frame = CGRectMake(topRegion.origin.x - 3.5f, topRegion.origin.y + topRegion.size.height - 4, 7, 4);
                }
                
                if (topRegion.origin.x + topRegion.size.width == middleRegion.origin.x + middleRegion.size.width)
                {
                    topCornerRight.hidden = false;
                    topCornerRight.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkCornerRL];
                    topCornerRight.frame = CGRectMake(topRegion.origin.x + topRegion.size.width - 4, topRegion.origin.y + topRegion.size.height - 3.5f, 4, 7);
                }
                else if (topRegion.origin.x + topRegion.size.width < middleRegion.origin.x + middleRegion.size.width - 3.5f)
                {
                    topCornerRight.hidden = false;
                    topCornerRight.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkCornerBT];
                    topCornerRight.frame = CGRectMake(topRegion.origin.x + topRegion.size.width - 3.5f, topRegion.origin.y + topRegion.size.height - 4, 7, 4);
                }
                else if (bottomRegion.size.height == 0 && topRegion.origin.x < middleRegion.origin.x + middleRegion.size.width - 3.5f && topRegion.origin.x + topRegion.size.width > middleRegion.origin.x + middleRegion.size.width + 3.5f)
                {
                    topCornerRight.hidden = false;
                    topCornerRight.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkCornerTB];
                    topCornerRight.frame = CGRectMake(middleRegion.origin.x + middleRegion.size.width - 3.5f, middleRegion.origin.y, 7, 4);
                }
            }
            
            if (middleRegion.size.height != 0 && bottomRegion.size.height != 0)
            {
                if (middleRegion.origin.x == bottomRegion.origin.x)
                {
                    bottomCornerLeft.hidden = false;
                    bottomCornerLeft.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkCornerLR];
                    bottomCornerLeft.frame = CGRectMake(middleRegion.origin.x, middleRegion.origin.y + middleRegion.size.height - 3.5f, 4, 7);
                }
                
                if (bottomRegion.origin.x + bottomRegion.size.width < middleRegion.origin.x + middleRegion.size.width - 3.5f)
                {
                    bottomCornerRight.hidden = false;
                    bottomCornerRight.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkCornerTB];
                    bottomCornerRight.frame = CGRectMake(bottomRegion.origin.x + bottomRegion.size.width - 3.5f, bottomRegion.origin.y, 7, 4);
                }
            }
            
            if (!topView.hidden)
                [linkHighlightedViews addObject:topView];
            if (!middleView.hidden)
                [linkHighlightedViews addObject:middleView];
            if (!bottomView.hidden)
                [linkHighlightedViews addObject:bottomView];
            
            if (!topCornerLeft.hidden)
                [linkHighlightedViews addObject:topCornerLeft];
            if (!topCornerRight.hidden)
                [linkHighlightedViews addObject:topCornerRight];
            if (!bottomCornerLeft.hidden)
                [linkHighlightedViews addObject:bottomCornerLeft];
            if (!bottomCornerRight.hidden)
                [linkHighlightedViews addObject:bottomCornerRight];
            
            for (UIView *partView in linkHighlightedViews)
            {
                partView.frame = CGRectOffset(partView.frame, _textModel.frame.origin.x, _textModel.frame.origin.y + 1);
                [[_contentModel boundView] addSubview:partView];
            }
            
            _currentLinkSelectionViews = linkHighlightedViews;
        }
    }
}

- (void)updateAssets {
    [super updateAssets];
    
    _shareButtonModel.image = [[TGTelegraphConversationMessageAssetsSource instance] systemShareButton];
}

- (void)sharePressed {
    [_context.companionHandle requestAction:@"fastForwardMessage" options:@{@"mid": @(_mid)}];
}

- (void)setupContentModel:(TGModernViewStorage *)viewStorage {
    [self removeContentModel:viewStorage];
    
    if (_replyHeader != nil || _caption.length != 0 || _forwardPeer != nil || _viaUser != nil)
    {
        static UIColor *incomingDateColor = nil;
        static UIColor *outgoingDateColor = nil;
        
        static TGTelegraphConversationMessageAssetsSource *assetsSource = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            assetsSource = [TGTelegraphConversationMessageAssetsSource instance];
            incomingDateColor = UIColorRGBA(0x525252, 0.6f);
            outgoingDateColor = UIColorRGBA(0x008c09, 0.8f);
        });
        
        _backgroundModel = [[TGTextMessageBackgroundViewModel alloc] initWithType:(_incomingAppearance) ? TGTextMessageBackgroundIncoming : TGTextMessageBackgroundOutgoing];
        [self insertSubmodel:_backgroundModel belowSubmodel:_imageModel];
        if (_isChannel) {
            [_backgroundModel setPartialMode:false];
        }
        
        _contentModel = [[TGModernFlatteningViewModel alloc] init];
        _contentModel.viewUserInteractionDisabled = true;
        [self insertSubmodel:_contentModel aboveSubmodel:_backgroundModel];
        
        if (_forwardPeer != nil)
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
            
            NSString *authorName = @"";
            
            if ([_forwardPeer isKindOfClass:[TGUser class]]) {
                _forwardedPeerId = ((TGUser *)_forwardPeer).uid;
                authorName = ((TGUser *)_forwardPeer).displayName;
            } else if ([_forwardPeer isKindOfClass:[TGConversation class]]) {
                _forwardedPeerId = ((TGConversation *)_forwardPeer).conversationId;
                authorName = ((TGConversation *)_forwardPeer).chatTitle;
            }
            
            if ([_forwardAuthor isKindOfClass:[TGUser class]]) {
                authorName = [[NSString alloc] initWithFormat:@"%@ (%@)", authorName, ((TGUser *)_forwardAuthor).displayName];
            }
            
            NSString *text = [[NSString alloc] initWithFormat:TGLocalizedStatic(@"Message.ForwardedMessage"), authorName];
            
            NSMutableArray *additionalAttributes = [[NSMutableArray alloc] init];
            NSMutableArray *textCheckingResults = [[NSMutableArray alloc] init];
            
            NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageForwardNameFont], (NSString *)kCTFontAttributeName, nil];
            
            if (_viaUser != nil) {
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
            _forwardedHeaderModel.textCheckingResults = textCheckingResults;
            if (formatNameRange.location != NSNotFound && authorName.length != 0)
            {
                NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                [additionalAttributes addObjectsFromArray:@[[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes]];
            }
            _forwardedHeaderModel.additionalAttributes = additionalAttributes;
            
            [_contentModel addSubmodel:_forwardedHeaderModel];
        }
        
        if (_authorPeer != nil)
        {
            NSString *title = @"";
            if ([_authorPeer isKindOfClass:[TGUser class]]) {
                title = ((TGUser *)_authorPeer).displayName;
            } else if ([_authorPeer isKindOfClass:[TGConversation class]]) {
                title = ((TGConversation *)_authorPeer).chatTitle;
            }
            _authorNameModel = [[TGModernTextViewModel alloc] initWithText:title font:[[TGTelegraphConversationMessageAssetsSource instance] messageAuthorNameFont]];
            [_contentModel addSubmodel:_authorNameModel];
            _authorNameModel.textColor = _authorNameColor;
            
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
        
        if (_viaUser != nil && _forwardedHeaderModel == nil) {
            NSString *formatString = TGLocalized(@"Conversation.MessageViaUser");
            NSString *viaUserName = [@"@" stringByAppendingString:_viaUser.userName];
            //viaUserName = @"qwoifehiqowfhipoqewipfhqweiopfhpoiqwehfiohpqiew";
            NSRange range = [formatString rangeOfString:@"%@"];
            
            _viaUserModel = [[TGModernTextViewModel alloc] initWithText:[[NSString alloc] initWithFormat:formatString, viaUserName] font:[[TGTelegraphConversationMessageAssetsSource instance] messageAuthorNameFont]];
            if (range.location != NSNotFound) {
                _viaUserModel.textCheckingResults = @[[[TGTextCheckingResult alloc] initWithRange:NSMakeRange(range.location, viaUserName.length) type:TGTextCheckingResultTypeBold contents:nil]];
            }
            _viaUserModel.textColor = _incomingAppearance ? TGAccentColor() : UIColorRGB(0x00a700);
            [_contentModel addSubmodel:_viaUserModel];
        }
        
        if (_replyHeader != nil)
        {
            _replyMessageId = _replyHeader.mid;
            
            _replyHeaderModel = [TGContentBubbleViewModel replyHeaderModelFromMessage:_replyHeader peer:_replyAuthor incoming:_incomingAppearance system:false];
            [_contentModel addSubmodel:_replyHeaderModel];
        }
        
        bool hasCaption = _caption.length != 0;
        
        if (_caption.length != 0) {
            _authorSignatureModel.text = _authorSignature;
        }
        
        if (hasCaption)
        {
            int daytimeVariant = 0;
            NSString *dateText = [TGDateUtils stringForShortTime:(int)_message.date daytimeVariant:&daytimeVariant];
            _dateModel = [[TGModernDateViewModel alloc] initWithText:dateText textColor:_incomingAppearance ? incomingDateColor : outgoingDateColor daytimeVariant:daytimeVariant];
            [_contentModel addSubmodel:_dateModel];
            
            if (!_incoming)
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
                        [self insertSubmodel:_checkFirstModel aboveSubmodel:_contentModel];
                        [self insertSubmodel:_checkSecondModel aboveSubmodel:_contentModel];
                    }
                    _checkFirstModel.alpha = 0.0f;
                    _checkSecondModel.alpha = 0.0f;
                }
                else if (_deliveryState == TGMessageDeliveryStateDelivered)
                {
                    if (!_incomingAppearance) {
                        [_contentModel addSubmodel:_checkFirstModel];
                    }
                    _checkFirstEmbeddedInContent = true;
                    
                    if (!_incomingAppearance) {
                        if (_read)
                        {
                            [_contentModel addSubmodel:_checkSecondModel];
                            _checkSecondEmbeddedInContent = true;
                        }
                        else
                        {
                            [self insertSubmodel:_checkSecondModel aboveSubmodel:_contentModel];
                            _checkSecondModel.alpha = 0.0f;
                        }
                    }
                }
            }
            
            _textModel = [[TGModernTextViewModel alloc] initWithText:_caption font:textFontForSize(TGGetMessageViewModelLayoutConstants()->textFontSize - 1)];
            _textModel.textCheckingResults = _textCheckingResults;
            _textModel.textColor = [assetsSource messageTextColor];
            if (_message.isBroadcast)
                _textModel.additionalTrailingWidth += 10.0f;
            [_contentModel addSubmodel:_textModel];
            
            if (_messageViews != nil) {
                _messageViewsModel = [[TGMessageViewsViewModel alloc] init];
                _messageViewsModel.type = _incomingAppearance ? TGMessageViewsViewTypeIncoming : TGMessageViewsViewTypeOutgoing;
                _messageViewsModel.count = _messageViews.viewCount;
                [self addSubmodel:_messageViewsModel];
                _messageViewsModel.hidden = _deliveryState != TGMessageDeliveryStateDelivered;
            }
        }
        
        if (_caption.length == 0)
        {
            [_imageModel setTimestampString:[self timestampString] signatureString:_authorSignature displayCheckmarks:!_incoming && _deliveryState != TGMessageDeliveryStateFailed checkmarkValue:(_incoming ? 0 : ((_deliveryState == TGMessageDeliveryStateDelivered ? 1 : 0) + (_read ? 1 : 0))) displayViews:_messageViews != nil viewsValue:_messageViews.viewCount animated:false];
            [_imageModel setDisplayTimestampProgress:_deliveryState == TGMessageDeliveryStatePending];
            _imageModel.timestampHidden = false;
        }
        else
        {
            _imageModel.timestampHidden = true;
        }
        
        if (viewStorage != nil) {
            
        }
    } else {
        [self removeContentModel:viewStorage];
    }
}

- (void)removeContentModel:(TGModernViewStorage *)viewStorage {
    [self removeSubmodel:_backgroundModel viewStorage:viewStorage];
    _backgroundModel = nil;
    
    [self removeSubmodel:_contentModel viewStorage:viewStorage];
    
    _forwardedHeaderModel = nil;
    _authorNameModel = nil;
    _textModel = nil;
    _dateModel = nil;
    _authorSignatureModel = nil;
    
    [self removeSubmodel:_messageViewsModel viewStorage:viewStorage];
    _messageViewsModel = nil;
    
    [self removeSubmodel:_checkFirstModel viewStorage:viewStorage];
    _checkFirstModel = nil;
    
    [self removeSubmodel:_checkSecondModel viewStorage:viewStorage];
    _checkSecondModel = nil;
    
    [self removeSubmodel:_progressModel viewStorage:viewStorage];
    _progressModel = nil;
    
    [_imageModel setTimestampString:[self timestampString] signatureString:_authorSignature displayCheckmarks:!_incoming && _deliveryState != TGMessageDeliveryStateFailed checkmarkValue:(_incoming ? 0 : ((_deliveryState == TGMessageDeliveryStateDelivered ? 1 : 0) + (_read ? 1 : 0))) displayViews:_messageViews != nil viewsValue:_messageViews.viewCount animated:false];
    [_imageModel setDisplayTimestampProgress:_deliveryState == TGMessageDeliveryStatePending];
    
    [_imageModel setTimestampString:[self timestampString] signatureString:_authorSignature displayCheckmarks:!_incoming && _deliveryState != TGMessageDeliveryStateFailed checkmarkValue:(_incoming ? 0 : ((_deliveryState == TGMessageDeliveryStateDelivered ? 1 : 0) + (_read ? 1 : 0))) displayViews:_messageViews != nil viewsValue:_messageViews.viewCount animated:false];
    [_imageModel setDisplayTimestampProgress:_deliveryState == TGMessageDeliveryStatePending];
    _imageModel.timestampHidden = false;
}

@end
