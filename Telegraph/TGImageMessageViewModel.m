#import "TGImageMessageViewModel.h"

#import "TGImageMediaAttachment.h"
#import "TGUser.h"
#import "TGMessage.h"

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

@interface TGImageMessageViewModel () <UIGestureRecognizerDelegate, TGDoubleTapGestureRecognizerDelegate, TGMessageImageViewDelegate>
{
    TGModernViewContext *_context;
    
    bool _incoming;
    TGMessageDeliveryState _deliveryState;
    bool _read;
    int _date;
    int32_t _messageLifetime;
    
    NSString *_legacyThumbnailCacheUri;
    
    bool _hasAvatar;
    
    TGModernImageViewModel *_unsentButtonModel;
    
    float _progress;
    bool _progressVisible;
    
    TGDoubleTapGestureRecognizer *_boundDoubleTapRecognizer;
    UITapGestureRecognizer *_unsentButtonTapRecognizer;
    
    TGInstantPreviewTouchAreaModel *_instantPreviewTouchAreaModel;
    
    UIImageView *_temporaryHighlightView;
    
    CGPoint _boundOffset;
    
    bool _mediaIsAvailable;
}

@end

@implementation TGImageMessageViewModel

- (instancetype)initWithMessage:(TGMessage *)message imageInfo:(TGImageInfo *)imageInfo author:(TGUser *)author context:(TGModernViewContext *)context
{
    self = [super initWithAuthor:author context:context];
    if (self != nil)
    {
        _previewEnabled = true;
        
        _context = context;
        
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
        
        _hasAvatar = author != nil;
        
        static TGTelegraphConversationMessageAssetsSource *assetsSource = nil;
        
        static UIImage *placeholderImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            assetsSource = [TGTelegraphConversationMessageAssetsSource instance];
            
            placeholderImage = [[UIImage imageNamed:@"ModernMessageImagePlaceholder.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16];
        });
        
        _needsEditingCheckButton = true;
        
        _mid = message.mid;
        _incoming = !message.outgoing;
        _deliveryState = message.deliveryState;
        _read = !message.unread;
        _date = (int32_t)message.date;
        _messageLifetime = message.messageLifetime;
        
        CGSize imageSize = CGSizeZero;
        _imageModel = [[TGMessageImageViewModel alloc] initWithUri:[imageInfo imageUrlForLargestSize:NULL]];
        
        CGSize imageOriginalSize = CGSizeMake(1, 1);
        [imageInfo imageUrlForLargestSize:&imageOriginalSize];
        imageSize = imageOriginalSize;
        
        _imageModel.skipDrawInContext = true;
        
        CGSize renderSize = CGSizeZero;
        [TGImageMessageViewModel calculateImageSizesForImageSize:imageSize thumbnailSize:&imageSize renderSize:&renderSize];
        
        _imageModel.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        [self addSubmodel:_imageModel];
        
        [_imageModel setTimestampString:[TGDateUtils stringForShortTime:(int)message.date] displayCheckmarks:!_incoming && _deliveryState != TGMessageDeliveryStateFailed checkmarkValue:(_incoming ? 0 : ((_deliveryState == TGMessageDeliveryStateDelivered ? 1 : 0) + (_read ? 1 : 0))) animated:false];
        [_imageModel setDisplayTimestampProgress:_deliveryState == TGMessageDeliveryStatePending];
        [_imageModel setIsBroadcast:message.isBroadcast];
        
        if (!_incoming)
        {
            /*_checkFirstModel = [[TGModernImageViewModel alloc] initWithImage:[self checkCompleteImage]];
            _checkSecondModel = [[TGModernImageViewModel alloc] initWithImage:[self checkPartialImage]];*/
            
            if (_deliveryState == TGMessageDeliveryStatePending)
            {
                /*_progressModel = [[TGModernClockProgressViewModel alloc] initWithType:(TGModernClockProgressType)[self clockProgressType]];
                [self addSubmodel:_progressModel];
                
                [self addSubmodel:_checkFirstModel];
                [self addSubmodel:_checkSecondModel];
                _checkFirstModel.alpha = 0.0f;
                _checkSecondModel.alpha = 0.0f;*/
            }
            else if (_deliveryState == TGMessageDeliveryStateFailed)
            {
                [self addSubmodel:[self unsentButtonModel]];
            }
            else if (_deliveryState == TGMessageDeliveryStateDelivered)
            {
                /*[_contentModel addSubmodel:_checkFirstModel];
                _checkFirstEmbeddedInContent = true;
                
                if (_read)
                {
                    [_contentModel addSubmodel:_checkSecondModel];
                    _checkSecondEmbeddedInContent = true;
                }
                else
                {
                    [self addSubmodel:_checkSecondModel];
                    _checkSecondModel.alpha = 0.0f;
                }*/
            }
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
        
        _instantPreviewTouchAreaModel.viewUserInteractionDisabled = !_mediaIsAvailable;
        
        [self addSubmodel:_instantPreviewTouchAreaModel];
    }
}

- (NSString *)stringForLifetime:(int32_t)remainingSeconds
{
    NSString *text = nil;
    
    if (remainingSeconds < 60)
        text = [[NSString alloc] initWithFormat:@"%ds", remainingSeconds];
    else if (remainingSeconds < 60 * 60)
        text = [[NSString alloc] initWithFormat:@"%dm", (remainingSeconds + 1) / 60];
    else if (remainingSeconds < 60 * 60 * 24)
        text = [[NSString alloc] initWithFormat:@"%dh", (remainingSeconds + 1) / (60 * 60)];
    else
        text = [[NSString alloc] initWithFormat:@"%dd", (remainingSeconds + 1) / (60 * 60 * 24)];
    
    return text;
}

- (NSString *)defaultAdditionalDataString
{
    if (_messageLifetime != 0)
        return [self stringForLifetime:_messageLifetime];
    
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

    [_imageModel setUri:imageUri];
}

+ (void)calculateImageSizesForImageSize:(in CGSize)imageSize thumbnailSize:(out CGSize *)thumbnailSize renderSize:(out CGSize *)renderSize
{
    CGFloat maxSide = TGIsPad() ? 312.0f : 246.0f;
    CGSize imageTargetMaxSize = CGSizeMake(maxSide, maxSide);
    CGSize imageScalingMaxSize = CGSizeMake(imageTargetMaxSize.width - 18.0f, imageTargetMaxSize.height - 18.0f);
    CGSize imageTargetMinSize = CGSizeMake(128.0f, 128.0f);
    
    CGFloat imageAspect = 1.0f;
    if (imageSize.width > 1.0f - FLT_EPSILON && imageSize.height > 1.0f - FLT_EPSILON)
        imageAspect = imageSize.width / imageSize.height;
    
    if (imageSize.width < imageScalingMaxSize.width || imageSize.height < imageScalingMaxSize.height)
    {
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

- (NSString *)filterForMessage:(TGMessage *)__unused message imageSize:(CGSize)imageSize sourceSize:(CGSize)sourceSize
{
    return [[NSString alloc] initWithFormat:@"%@:%dx%d,%dx%d", @"attachmentImageOutgoing", (int)imageSize.width, (int)imageSize.height, (int)sourceSize.width, (int)sourceSize.height];
}

- (CGSize)minimumImageSizeForMessage:(TGMessage *)__unused message
{
    return CGSizeMake(90, 90);
}

- (bool)instantPreviewGesture
{
    return false;
}

- (void)setTemporaryHighlighted:(bool)temporaryHighlighted viewStorage:(TGModernViewStorage *)__unused viewStorage
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

- (void)updateMediaAvailability:(bool)mediaIsAvailable viewStorage:(TGModernViewStorage *)__unused viewStorage
{
    _mediaIsAvailable = mediaIsAvailable;
    
    [self updateImageOverlay:false];
}

- (void)updateMediaVisibility
{
    _imageModel.mediaVisible = [_context isMediaVisibleInMessage:_mid];
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage
{
    [super updateMessage:message viewStorage:viewStorage];
    
    _mid = message.mid;
    
    if (_deliveryState != message.deliveryState || (!_incoming && _read != !message.unread))
    {
        _deliveryState = message.deliveryState;
        _read = !message.unread;
        
        [_imageModel setTimestampString:[TGDateUtils stringForShortTime:(int)message.date] displayCheckmarks:!_incoming && _deliveryState != TGMessageDeliveryStateFailed checkmarkValue:(_incoming ? 0 : ((_deliveryState == TGMessageDeliveryStateDelivered ? 1 : 0) + (_read ? 1 : 0))) animated:true];
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

- (void)updateImageOverlay:(bool)animated
{
    _instantPreviewTouchAreaModel.viewUserInteractionDisabled = !_mediaIsAvailable;
    
    if (_progressVisible)
    {
        [_imageModel setOverlayType:TGMessageImageViewOverlayProgress animated:false];
        [_imageModel setProgress:_progress animated:animated];
    }
    else if (!_mediaIsAvailable)
    {
        [_imageModel setOverlayType:TGMessageImageViewOverlayDownload animated:false];
        [_imageModel setProgress:0.0f animated:false];
    }
    else
        [_imageModel setOverlayType:[self defaultOverlayActionType] animated:animated];
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
    
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
    
    [_imageModel bindViewToContainer:container viewStorage:viewStorage];
    [_imageModel boundView].frame = CGRectOffset([_imageModel boundView].frame, itemPosition.x, itemPosition.y);
    ((TGMessageImageViewContainer *)[_imageModel boundView]).imageView.delegate = self;
}

- (CGRect)effectiveContentFrame
{
    return _imageModel.frame;
}

- (UIView *)referenceViewForImageTransition
{
    return [_imageModel boundView];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    _boundOffset = CGPointZero;
    
    [self updateEditingState:nil viewStorage:nil animationDelay:-1.0];
    
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    _boundDoubleTapRecognizer = [[TGDoubleTapGestureRecognizer alloc] initWithTarget:self action:@selector(messageDoubleTapGesture:)];
    _boundDoubleTapRecognizer.delegate = self;
    
    UIView *backgroundView = [_imageModel boundView];
    [backgroundView addGestureRecognizer:_boundDoubleTapRecognizer];
    
    if (_unsentButtonModel != nil)
    {
        _unsentButtonTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unsentButtonTapGesture:)];
        [[_unsentButtonModel boundView] addGestureRecognizer:_unsentButtonTapRecognizer];
    }
    
    _imageModel.mediaVisible = [_context isMediaVisibleInMessage:_mid];
    
    ((TGMessageImageViewContainer *)[_imageModel boundView]).imageView.delegate = self;
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    _boundOffset = CGPointZero;
    
    UIView *imageView = [_imageModel boundView];
    [imageView removeGestureRecognizer:_boundDoubleTapRecognizer];
    _boundDoubleTapRecognizer.delegate = nil;
    _boundDoubleTapRecognizer = nil;
    
    ((TGMessageImageViewContainer *)imageView).imageView.delegate = self;
    
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
    
    [super unbindView:viewStorage];
}

- (void)messageDoubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        if ([self instantPreviewGesture])
        {
            [_context.companionHandle requestAction:@"closeMediaRequested" options:@{@"mid": @(_mid)}];
        }
        else
        {
            if (recognizer.longTapped)
                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
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

- (bool)gestureRecognizerShouldHandleLongTap:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
    return ![self instantPreviewGesture];
}

- (void)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer didBeginAtPoint:(CGPoint)__unused point
{
}

- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer shouldFailTap:(CGPoint)__unused point
{
    return 3;
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
    return ![self instantPreviewGesture];
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    TGMessageViewModelLayoutConstants const *layoutConstants = TGGetMessageViewModelLayoutConstants();
    
    CGFloat topSpacing = (_collapseFlags & TGModernConversationItemCollapseTop) ? layoutConstants->topInsetCollapsed : layoutConstants->topInset;
    CGFloat bottomSpacing = (_collapseFlags & TGModernConversationItemCollapseBottom) ? layoutConstants->bottomInsetCollapsed : layoutConstants->bottomInset;
    
    CGFloat avatarOffset = 0.0f;
    if (_hasAvatar)
        avatarOffset = 38.0f;
    
    CGFloat unsentOffset = 0.0f;
    if (!_incoming && _deliveryState == TGMessageDeliveryStateFailed)
        unsentOffset = 29.0f;
    
    CGRect imageFrame = CGRectMake(_incoming ? (avatarOffset + layoutConstants->leftImageInset) : (containerSize.width - _imageModel.frame.size.width - layoutConstants->rightImageInset - unsentOffset), topSpacing, _imageModel.frame.size.width, _imageModel.frame.size.height);
    if (_incoming && _editing)
        imageFrame.origin.x += 42.0f;
    _imageModel.frame = imageFrame;
    
    _instantPreviewTouchAreaModel.frame = imageFrame;
    
    if (_unsentButtonModel != nil)
    {
        _unsentButtonModel.frame = CGRectMake(containerSize.width - _unsentButtonModel.frame.size.width - 9, _imageModel.frame.size.height + topSpacing + bottomSpacing - _unsentButtonModel.frame.size.height - ((_collapseFlags & TGModernConversationItemCollapseBottom) ? 5 : 6), _unsentButtonModel.frame.size.width, _unsentButtonModel.frame.size.height);
    }
    
    CGRect frame = self.frame;
    frame.size = CGSizeMake(containerSize.width, _imageModel.frame.size.height + topSpacing + bottomSpacing);
    self.frame = frame;
    
    [super layoutForContainerSize:containerSize];
}

- (int)defaultOverlayActionType
{
    return _isSecret ? TGMessageImageViewOverlaySecret : TGMessageImageViewOverlayNone;
}

@end
