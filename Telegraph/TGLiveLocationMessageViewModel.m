#import "TGLiveLocationMessageViewModel.h"

#import "TGTelegramNetworking.h"
#import <LegacyComponents/TGDateUtils.h>
#import <LegacyComponents/TGFont.h>
#import <LegacyComponents/TGImageUtils.h>

#import <LegacyComponents/LegacyComponentsGlobals.h>
#import <LegacyComponents/TGUser.h>
#import <LegacyComponents/TGMessage.h>
#import <LegacyComponents/TGConversation.h>
#import <LegacyComponents/TGLocationMediaAttachment.h>

#import <LegacyComponents/TGDoubleTapGestureRecognizer.h>

#import <LegacyComponents/TGViewController.h>

#import "TGMessageImageViewModel.h"
#import "TGModernTextViewModel.h"
#import "TGModernButtonViewModel.h"
#import "TGModernImageViewModel.h"
#import "TGModernButtonView.h"
#import "TGModernFlatteningViewModel.h"
#import "TGLiveLocationElapsedViewModel.h"
#import "TGModernLetteredAvatarViewModel.h"
#import "TGLocationPulseViewModel.h"
#import "TGReplyHeaderModel.h"
#import "TGImageMessageViewModel.h"

@interface TGLiveLocationMessageViewModel ()
{
    TGMessage *_message;
    int32_t _period;
    bool _expired;
    bool _animated;
    
    TGDoubleTapGestureRecognizer *_boundDoubleTapRecognizer;
    
    TGModernFlatteningViewModel *_bottomModel;
    TGModernTextViewModel *_titleModel;
    TGModernTextViewModel *_subtitleModel;
    
    TGMessageImageViewModel *_imageModel;
    TGLocationPulseViewModel *_pulseModel;
    TGModernImageViewModel *_pinModel;
    TGModernLetteredAvatarViewModel *_avatarModel;
    
    TGLiveLocationElapsedViewModel *_elapsedModel;
    
    SMetaDisposable *_remainingDisposable;
}
@end

@implementation TGLiveLocationMessageViewModel

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude period:(int32_t)period message:(TGMessage *)message authorPeer:(id)authorPeer useAuthor:(bool)useAuthor context:(TGModernViewContext *)context viaUser:(TGUser *)viaUser
{
    _inhibitChecks = true;
    _ignoreEditing = true;
    _ignoreViews = true;
    _inhibitShare = true;
    _inhibitContentAnimation = true;
    self = [super initWithMessage:message authorPeer:useAuthor ? authorPeer : nil viaUser:viaUser context:context];
    if (self != nil)
    {
        _message = message;
        _period = period;
        
        static UIColor *incomingDetailColor = nil;
        static UIColor *outgoingDetailColor = nil;
        static UIImage *incomingButtonIcon = nil;
        static UIImage *outgoingButtonIcon = nil;

        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            incomingDetailColor = UIColorRGB(0x999999);
            outgoingDetailColor = UIColorRGB(0x2da32e);
            
            incomingButtonIcon = TGTintedImage(TGComponentsImageNamed(@"LocationMessageLiveIcon"), TGAccentColor());
            outgoingButtonIcon = TGTintedImage(TGComponentsImageNamed(@"LocationMessageLiveIcon"), outgoingDetailColor);
        });
        
        int32_t currentTime = (int32_t)[[TGTelegramNetworking instance] globalTime];
        _expired = currentTime >= message.date + period;
        
        _bottomModel = [[TGModernFlatteningViewModel alloc] init];
        _bottomModel.viewUserInteractionDisabled = true;
        [self addSubmodel:_bottomModel];
        
        _titleModel = [[TGModernTextViewModel alloc] initWithText:TGLocalized(@"Conversation.LiveLocation") font:TGCoreTextMediumFontOfSize(16.0f)];
        _titleModel.maxNumberOfLines = 1;
        _titleModel.textColor = [UIColor blackColor];
        [_bottomModel addSubmodel:_titleModel];
        
        NSString *subtitle = [TGDateUtils stringForRelativeUpdate:[message actualDate]];
        _subtitleModel = [[TGModernTextViewModel alloc] initWithText:subtitle font:TGCoreTextSystemFontOfSize(13.0f)];
        _subtitleModel.maxNumberOfLines = 1;
        _subtitleModel.textColor = _incomingAppearance ? incomingDetailColor : outgoingDetailColor;
        [_bottomModel addSubmodel:_subtitleModel];
    
        CGSize size;
        CGSize renderSize;
        [TGImageMessageViewModel calculateImageSizesForImageSize:CGSizeMake(1280, 640) thumbnailSize:&size renderSize:&renderSize squareAspect:false];
        NSString *imageUri = [[NSString alloc] initWithFormat:@"map-thumbnail://?latitude=%f&longitude=%f&width=%d&height=%d&noPin=1&flat=1&cornerRadius=15&offset=-18", latitude, longitude, (int)size.width, (int)size.height];
        
        if (![TGViewController hasLargeScreen])
            size.width += 10.0f;
        
        _imageModel = [[TGMessageImageViewModel alloc] initWithUri:imageUri];
        [_imageModel setPresentation:_context.presentation];
        _imageModel.ignoresInvertColors = false;
        _imageModel.skipDrawInContext = true;
        _imageModel.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        [self addSubmodel:_imageModel];
        
        if (!_expired)
        {
            _imageModel.timestampHidden = true;
            
            _pulseModel = [[TGLocationPulseViewModel alloc] init];
            _pulseModel.skipDrawInContext = true;
            _pulseModel.viewUserInteractionDisabled = true;
            [self addSubmodel:_pulseModel];
        }
        else
        {
            _imageModel.timestampHidden = false;
        }
        
        [_imageModel setTimestampString:[self timestampString] signatureString:nil displayCheckmarks:!_incoming && _deliveryState != TGMessageDeliveryStateFailed checkmarkValue:(_incoming ? 0 : ((_deliveryState == TGMessageDeliveryStateDelivered ? 1 : 0) + (_read ? 1 : 0))) displayViews:false viewsValue:0 animated:false];
        
        _pinModel = [[TGModernImageViewModel alloc] initWithImage:TGImageNamed(@"LocationMessagePinSmallBackground")];
        [_pinModel setViewUserInteractionDisabled:true];
        [self addSubmodel:_pinModel];
        
        static UIImage *placeholder = nil;
        static dispatch_once_t onceToken2;
        dispatch_once(&onceToken2, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(42.0f, 42.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            //!placeholder
            CGContextSetFillColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 42.0f, 42.0f));
            
            placeholder = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        _avatarModel = [[TGModernLetteredAvatarViewModel alloc] initWithSize:CGSizeMake(42, 42) placeholder:placeholder];
        _avatarModel.skipDrawInContext = true;
        _avatarModel.fontSize = 20.0f;
        [_avatarModel setViewUserInteractionDisabled:true];
        [self addSubmodel:_avatarModel];
        
        if ([authorPeer isKindOfClass:[TGUser class]])
        {
            TGUser *user = (TGUser *)authorPeer;
            if (user.photoUrlSmall.length > 0)
                [_avatarModel setAvatarUri:user.photoUrlSmall];
            else
                [_avatarModel setAvatarFirstName:user.firstName lastName:user.lastName uid:user.uid];
        }
        else if ([authorPeer isKindOfClass:[TGConversation class]])
        {
            TGConversation *conversation = (TGConversation *)authorPeer;
            if (conversation.chatPhotoSmall.length > 0)
                [_avatarModel setAvatarUri:conversation.chatPhotoSmall];
            else
                [_avatarModel setAvatarTitle:conversation.chatTitle groupId:conversation.conversationId];
        }
        
        if (!_expired)
        {
            _remainingDisposable = [[SMetaDisposable alloc] init];
            
            _elapsedModel = [[TGLiveLocationElapsedViewModel alloc] initWithColor:_incomingAppearance ? TGAccentColor() : outgoingDetailColor];
            _elapsedModel.skipDrawInContext = true;
            [_elapsedModel setViewUserInteractionDisabled:true];
            [self addSubmodel:_elapsedModel];
        }
        else
        {
            _avatarModel.alpha = 0.5f;
        }
        
        [_contentModel removeSubmodel:(TGModernViewModel *)_dateModel viewStorage:nil];
        [_contentModel removeSubmodel:_authorNameModel viewStorage:nil];
        [_contentModel removeSubmodel:_authorSignatureModel viewStorage:nil];
        [_contentModel removeSubmodel:_adminModel viewStorage:nil];
        _authorNameModel = nil;
    }
    return self;
}

- (void)dealloc
{
    [_remainingDisposable dispose];
}

- (NSString *)timestampString
{
    return [TGDateUtils stringForShortTime:_date];
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    //_boundOffset = itemPosition;
    
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
    
    [_imageModel bindViewToContainer:container viewStorage:viewStorage];
    [_imageModel boundView].frame = CGRectOffset([_imageModel boundView].frame, itemPosition.x, itemPosition.y);
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    _boundDoubleTapRecognizer = [[TGDoubleTapGestureRecognizer alloc] initWithTarget:self action:@selector(messageDoubleTapGesture:)];
    _boundDoubleTapRecognizer.delegate = self;
    [[_imageModel boundView] addGestureRecognizer:_boundDoubleTapRecognizer];
    
    if (_elapsedModel != nil)
    {
        __weak TGLiveLocationMessageViewModel *weakSelf = self;
        [_remainingDisposable setDisposable:[_context.liveLocationRemaining(_message.mid) startWithNext:^(NSNumber *next)
        {
            __strong TGLiveLocationMessageViewModel *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf->_elapsedModel setRemaining:[next int32Value] period:strongSelf->_period];
        } error:nil completed:nil]];
    }
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    [[_imageModel boundView] removeGestureRecognizer:_boundDoubleTapRecognizer];
    _boundDoubleTapRecognizer.delegate = nil;
    _boundDoubleTapRecognizer = nil;
    
    [_remainingDisposable setDisposable:nil];
    
    [super unbindView:viewStorage];
}

- (void)buttonPressed
{
    [_context.companionHandle requestAction:@"locationPickerRequested" options:@{}];
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated
{
    TGLocationMediaAttachment *location = message.locationAttachment;
    int32_t currentTime = (int32_t)[[TGTelegramNetworking instance] globalTime];
    int32_t period = location.period;
    
    bool previousExpired = _expired;
    _expired = currentTime >= message.date + period;
    
    NSString *subtitle = [TGDateUtils stringForRelativeUpdate:[message actualDate]];
    if (![subtitle isEqualToString:_subtitleModel.text])
    {
        _subtitleModel.text = subtitle;
        [_bottomModel setNeedsSubmodelContentsUpdate];
        
        *sizeUpdated = true;
    }
    
    if (_expired != previousExpired)
    {
        _animated = true;
        *sizeUpdated = true;
    }
    
    if (!_expired && _message.mid != message.mid)
    {
        __weak TGLiveLocationMessageViewModel *weakSelf = self;
        [_remainingDisposable setDisposable:[_context.liveLocationRemaining(message.mid) startWithNext:^(NSNumber *next)
        {
            __strong TGLiveLocationMessageViewModel *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf->_elapsedModel setRemaining:[next int32Value] period:strongSelf->_period];
        } error:nil completed:nil]];
    }
    
    _message = message;
    _period = period;
    
    [super updateMessage:message viewStorage:viewStorage sizeUpdated:sizeUpdated];
    
    if (_expired)
    {
        if (!previousExpired)
        {
            [self removeSubmodel:_pulseModel viewStorage:viewStorage];
            _pulseModel = nil;
            
            [_imageModel setTimestampHidden:false animated:true];
        }
    }
    
    [_imageModel setTimestampString:[self timestampString] signatureString:nil displayCheckmarks:!_incoming && _deliveryState != TGMessageDeliveryStateFailed checkmarkValue:(_incoming ? 0 : ((_deliveryState == TGMessageDeliveryStateDelivered ? 1 : 0) + (_read ? 1 : 0))) displayViews:false viewsValue:0 animated:true];
    
    CGSize size;
    CGSize renderSize;
    [TGImageMessageViewModel calculateImageSizesForImageSize:CGSizeMake(1280, 640) thumbnailSize:&size renderSize:&renderSize squareAspect:false];

    NSString *imageUri = [[NSString alloc] initWithFormat:@"map-thumbnail://?latitude=%f&longitude=%f&width=%d&height=%d&noPin=1&flat=1&cornerRadius=15&offset=-18", location.latitude, location.longitude, (int)size.width, (int)size.height];

    [_imageModel setUri:imageUri];
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    if (_animated)
    {
        [[_elapsedModel boundView].superview insertSubview:[_elapsedModel boundView] belowSubview:[_imageModel boundView]];
        
        [UIView animateWithDuration:0.3 animations:^
        {
            [super layoutForContainerSize:containerSize];
            
            if (_expired)
            {
                [_bottomModel boundView].alpha = 0.0f;
                [_elapsedModel boundView].alpha = 0.0f;
                _avatarModel.alpha = 0.5f;
            }
        } completion:^(__unused BOOL finished)
        {
            _animated = false;
            
            if (_expired)
            {
                [self removeSubmodel:_elapsedModel viewStorage:nil];
                _elapsedModel = nil;
            }
        }];
    }
    else
    {
        [super layoutForContainerSize:containerSize];
    }
    
    [_bottomModel updateSubmodelContentsIfNeeded];
}

- (void)layoutContentForHeaderHeight:(CGFloat)headerHeight
{
    CGPoint offset = CGPointMake(_incomingAppearance ? -1.0f : 0.0f, headerHeight > 0 ? headerHeight + 5.0f : 0.0f);
    _imageModel.frame = CGRectMake(_contentModel.frame.origin.x - 6.0f + offset.x + TGScreenPixel, offset.y + _contentModel.frame.origin.y + TGScreenPixel, _imageModel.frame.size.width, _imageModel.frame.size.height);
    
    _bottomModel.frame = CGRectMake(_contentModel.frame.origin.x - 6.0f, CGRectGetMaxY(_contentModel.frame) - 50.0f, _contentModel.frame.size.width, 50.0f);
    
    _titleModel.frame = CGRectMake(7.0f, 3.0f , _titleModel.frame.size.width, _titleModel.frame.size.height);
    _subtitleModel.frame = CGRectMake(7.0f, 26.0f, _subtitleModel.frame.size.width, _subtitleModel.frame.size.height);
    
    _pulseModel.frame = CGRectMake(_imageModel.frame.origin.x + round(_imageModel.frame.size.width / 2.0f), _imageModel.frame.origin.y + round(_imageModel.frame.size.height / 2.0f) + 25.0f, 0.0f, 0.0f);
    _pinModel.frame = CGRectMake(_imageModel.frame.origin.x + round(_imageModel.frame.size.width / 2.0f) - 31.0f, _imageModel.frame.origin.y + round(_imageModel.frame.size.height / 2.0f) - 41.0f, 63.0f, 75.0f);
    
    _avatarModel.frame = CGRectMake(_pinModel.frame.origin.x + 10.0f + TGScreenPixel, _pinModel.frame.origin.y + 10.0f - TGScreenPixel, 42.0f, 42.0f);
    
    _elapsedModel.frame = CGRectMake(CGRectGetMaxX(_contentModel.frame) - 30.0f - 8.0f, CGRectGetMaxY(_contentModel.frame) - 30.0f - 8.0f, 30.0f, 30.0f);
}

- (CGSize)contentSizeForContainerSize:(CGSize)containerSize needsContentsUpdate:(bool *)needsContentsUpdate infoWidth:(CGFloat)__unused infoWidth
{
    CGSize titleContainerSize = CGSizeMake(MIN(200, containerSize.width - 18), containerSize.height);
    bool updateTitleContents = [_titleModel layoutNeedsUpdatingForContainerSize:titleContainerSize additionalTrailingWidth:0.0f layoutFlags:0];
    if (updateTitleContents)
        [_titleModel layoutForContainerSize:titleContainerSize];
    
    CGSize subtitleContainerSize = CGSizeMake(MAX(_subtitleModel.frame.size.width, containerSize.width - 30.0f), containerSize.height);
    bool updateSubitleContents = [_subtitleModel layoutNeedsUpdatingForContainerSize:subtitleContainerSize additionalTrailingWidth:0.0f layoutFlags:0];
    if (updateSubitleContents)
        [_subtitleModel layoutForContainerSize:subtitleContainerSize];
    
    if (updateTitleContents || updateSubitleContents)
        [_bottomModel setNeedsSubmodelContentsUpdate];
    
    *needsContentsUpdate = updateTitleContents || updateSubitleContents;
    
    CGFloat offsetX = TGScreenScaling() > 2 ? TGScreenPixel : 0.0f;
    CGFloat offsetY = _replyHeaderModel != nil ? 5.0f : 0.0f;
    if (_expired)
        offsetY -= 49.0f + TGScreenPixel;
    
    return CGSizeMake(_imageModel.frame.size.width - 15.0f - offsetX, _imageModel.frame.size.height + 44.0f + offsetY);
}

- (void)messageDoubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint point = [recognizer locationInView:[_contentModel boundView]];
        if (recognizer.longTapped)
        {
            [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
        }
        else if (_replyHeaderModel && CGRectContainsPoint(_replyHeaderModel.frame, point))
        {
            [_context.companionHandle requestAction:@"navigateToMessage" options:@{@"mid": @(_replyMessageId), @"sourceMid": @(_mid)}];
        }
        else
        {
            [_context.companionHandle requestAction:@"openMediaRequested" options:@{@"mid": @(_mid)}];
        }
    }
}

- (bool)gestureRecognizerShouldHandleLongTap:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
    return true;
}

- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer shouldFailTap:(CGPoint)__unused point
{
    return 3;
}

- (void)resumeInlineMedia
{
    [super resumeInlineMedia];
    [_pulseModel resume];
}

- (bool)isPreviewableAtPoint:(CGPoint)point
{
    return CGRectContainsPoint(_imageModel.frame, point);
}

@end
