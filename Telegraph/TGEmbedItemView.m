#import "TGEmbedItemView.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGEmbedPlayerView.h"
#import "TGEmbedInternalPlayerView.h"

#import "TGSharedPhotoSignals.h"
#import "TGSharedMediaUtils.h"
#import "TGSharedMediaSignals.h"

#import "TGMenuSheetController.h"

#import "TGEmbedPlayerController.h"
#import "TGEmbedPIPController.h"
#import "TGEmbedPIPPlaceholderView.h"

const CGFloat TGEmbedItemViewCornerRadius = 5.5f;

@interface TGEmbedItemView ()
{
    TGPIPSourceLocation *_location;
    
    CGSize _embedSize;
    TGWebPageMediaAttachment *_webPage;
    TGDocumentMediaAttachment *_document;
    
    UIView *_wrapperView;
    TGEmbedPlayerView *_playerView;
        
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    
    CGFloat _smallActivationHeight;
    bool _smallActivated;
    
    __weak TGEmbedPlayerController *_playerController;
    
    __weak TGEmbedPIPPlaceholderView *_placeholderView;
    bool _switchingToPIP;
    
    bool _hadPIPPlayer;
    
    bool _mayRequestFullscreenOnOrientationChange;
}
@end

@implementation TGEmbedItemView

@dynamic hasNoAboutInformation;

- (instancetype)initWithWebPageAttachment:(TGWebPageMediaAttachment *)webPage peerId:(int64_t)peerId messageId:(int32_t)messageId
{
    if (webPage.document == nil || [webPage.siteName.lowercaseString isEqualToString:@"coub"])
    {
        return [self initWithWebPageAttachment:webPage thumbnailSignal:nil peerId:peerId messageId:messageId];
    }
    else
    {
        SSignal *thumbnailSignal = nil;
        CGSize imageSize = CGSizeZero;
        bool hasSize = false;
        
        for (id attribute in webPage.document.attributes) {
            if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]]) {
                imageSize = ((TGDocumentAttributeImageSize *)attribute).size;
                hasSize = imageSize.width > 1.0f && imageSize.height >= 1.0f;
                break;
            } else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                imageSize = ((TGDocumentAttributeVideo *)attribute).size;
                hasSize = imageSize.width > 1.0f && imageSize.height >= 1.0f;
                break;
            }
        }
        
        if (!hasSize) {
            [webPage.document.thumbnailInfo imageUrlForLargestSize:&imageSize];
            hasSize = imageSize.width > 1.0f && imageSize.height >= 1.0f;
        }
        
        CGSize fitSize = CGSizeMake(320.0f, 320.0f);
        imageSize = TGFitSize(TGScaleToFill(imageSize, fitSize), fitSize);
        
        if (webPage.photo != nil)
        {
            thumbnailSignal = [TGSharedPhotoSignals squarePhotoThumbnail:webPage.photo ofSize:imageSize threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:nil downloadLargeImage:true placeholder:nil];
        }

        return [self initWithDocumentAttachment:webPage.document thumbnailSignal:thumbnailSignal peerId:peerId messageId:messageId];
    }
}

- (instancetype)initWithWebPageAttachment:(TGWebPageMediaAttachment *)webPage thumbnailSignal:(SSignal *)thumbnailSignal peerId:(int64_t)peerId messageId:(int32_t)messageId
{
    return [self initWithMediaAttachment:webPage thumbnailSignal:thumbnailSignal peerId:peerId messageId:messageId];
}

- (instancetype)initWithDocumentAttachment:(TGDocumentMediaAttachment *)attachment thumbnailSignal:(SSignal *)thumbnailSignal peerId:(int64_t)peerId messageId:(int32_t)messageId
{
    return [self initWithMediaAttachment:attachment thumbnailSignal:thumbnailSignal peerId:peerId messageId:messageId];
}

- (instancetype)initWithMediaAttachment:(TGMediaAttachment *)attachment thumbnailSignal:(SSignal *)thumbnailSignal peerId:(int64_t)peerId messageId:(int32_t)messageId
{
    self = [super initWithType:TGMenuSheetItemTypeDefault];
    if (self != nil)
    {
        _location = [[TGPIPSourceLocation alloc] initWithEmbed:true peerId:peerId messageId:messageId localId:0 webPage:nil];
        self.backgroundColor = [UIColor blackColor];
        
        _wrapperView = [[UIView alloc] initWithFrame:CGRectZero];
        _wrapperView.clipsToBounds = true;
        [self addSubview:_wrapperView];
        
        bool hasPIPPlayer = [TGEmbedPIPController hasPictureInPictureActiveForLocation:_location playerView:NULL];
        _hadPIPPlayer = hasPIPPlayer;
        
        if ([attachment isKindOfClass:[TGWebPageMediaAttachment class]])
        {
            _webPage = (TGWebPageMediaAttachment *)attachment;
            
            if (!hasPIPPlayer)
            {
                Class playerViewClass = [TGEmbedPlayerView playerViewClassForWebPage:_webPage onlySpecial:false];
                _playerView = [[playerViewClass alloc] initWithWebPageAttachment:_webPage thumbnailSignal:thumbnailSignal];
            }
        }
        else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
        {
            _document = (TGDocumentMediaAttachment *)attachment;
            
            if (!hasPIPPlayer)
                _playerView = [[TGEmbedInternalPlayerView alloc] initWithDocumentAttachment:_document thumbnailSignal:thumbnailSignal];
        }
        
        if (_playerView != nil)
        {
            [self _configurePlayerView];
            [_wrapperView addSubview:_playerView];
            
            [TGEmbedPIPController registerPlayerView:_playerView];
        }
        
        if (hasPIPPlayer)
        {
            TGEmbedPIPPlaceholderView *placeholderView = [[TGEmbedPIPPlaceholderView alloc] init];
            _placeholderView = placeholderView;
            _placeholderView.location = _location;
            _placeholderView.containerView = self;
            [_wrapperView addSubview:_placeholderView];
            
            [TGEmbedPIPController registerPlaceholderView:placeholderView];
        }
        
        CGSize screenSize = TGScreenSize();
        _smallActivationHeight = screenSize.width;
        
        CGSize dimensions = [self _dimensions];
        if (dimensions.width > dimensions.height)
            _mayRequestFullscreenOnOrientationChange = true;
    }
    return self;
}

- (void)setInPreviewContext:(bool)inPreviewContext
{
    _inPreviewContext = inPreviewContext;
    _playerView.disallowPIP = inPreviewContext;
}

- (void)_configurePlayerView
{
    __weak TGEmbedItemView *weakSelf = self;
    _playerView.roundCorners = UIRectCornerTopLeft | UIRectCornerTopRight;
    _playerView.requestFullscreen = ^(NSTimeInterval duration)
    {
        __strong TGEmbedItemView *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGEmbedPlayerController *controller = [[TGEmbedPlayerController alloc] initWithParentController:strongSelf.parentController playerView:strongSelf->_playerView transitionSourceFrame:^CGRect
        {
            __strong TGEmbedItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return CGRectZero;
            
            return [strongSelf convertRect:strongSelf->_playerView.initialFrame toView:nil];
        }];
        controller.transitionDuration = duration;
        controller.embedWrapperView = strongSelf;
        
        if (strongSelf.inPreviewContext)
            [controller setAboveStatusBar];
        
        strongSelf->_playerController = controller;
    };
    _playerView.requestPictureInPicture = ^(__unused TGEmbedPIPCorner corner)
    {
        __strong TGEmbedItemView *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_switchingToPIP = true;
        [TGEmbedPIPController startPictureInPictureWithPlayerView:strongSelf->_playerView location:strongSelf->_location corner:TGEmbedPIPCornerNone onTransitionBegin:^
        {
            __strong TGEmbedItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (![TGEmbedPIPController isSystemPictureInPictureAvailable])
            {
                bool inFullscreen = (strongSelf->_playerController != nil);
                [strongSelf.menuController dismissAnimated:!inFullscreen];
            }
            
            if (strongSelf->_playerController != nil)
                [strongSelf->_playerController dismissForPIP];
        } onTransitionFinished:^
        {
            if ([TGEmbedPIPController isSystemPictureInPictureAvailable])
                [strongSelf.menuController dismissAnimated:false];
        }];
    };
}

- (void)setHasNoAboutInformation:(bool)hasNoAboutInformation
{
    _playerView.roundCorners = hasNoAboutInformation ? UIRectCornerAllCorners : UIRectCornerTopLeft | UIRectCornerTopRight;
}

- (void)setOnMetadataLoaded:(void (^)(NSString *, NSString *))onMetadataLoaded
{
    _onMetadataLoaded = [onMetadataLoaded copy];
    _playerView.onMetadataLoaded = onMetadataLoaded;
}

- (TGEmbedPIPPlaceholderView *)pipPlaceholderView
{
    return _placeholderView;
}

- (void)reattachPlayerView
{
    _playerView.frame = _playerView.initialFrame;
    [_wrapperView addSubview:_playerView];
}

- (void)reattachPlayerView:(TGEmbedPlayerView *)playerView
{
    [_placeholderView removeFromSuperview];
    _placeholderView = nil;
    
    _playerView = playerView;
    [self reattachPlayerView];
    
    [self _configurePlayerView];
}

- (bool)shouldReattachPlayerBeforeTransition
{
    return false;
}

- (void)menuView:(TGMenuSheetView *)__unused menuView willAppearAnimated:(bool)__unused animated
{
    if (!_hadPIPPlayer)
        [_playerView setupWithEmbedSize:_embedSize];
    
    _playerView.disableWatermarkAction = self.inPreviewContext;
    _playerView.inhibitFullscreenButton = self.inPreviewContext;
}

- (void)menuView:(TGMenuSheetView *)__unused menuView didAppearAnimated:(bool)__unused animated
{
    if (self.inPreviewContext)
        [_playerView onLockInPlace];
}

- (void)menuView:(TGMenuSheetView *)__unused menuView willDisappearAnimated:(bool)__unused animated
{
    if (_playerView.superview != _wrapperView || _switchingToPIP)
        return;
    
    [_playerView hideControls];
    [_playerView pauseVideo];
}

- (bool)distractable
{
    return true;
}

#pragma mark -

- (void)_willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
    if (TGIsPad() || !_mayRequestFullscreenOnOrientationChange)
        return;
    
    if (_playerController == nil && UIInterfaceOrientationIsLandscape(orientation))
        [_playerView enterFullscreen:duration];
    else if (_playerController != nil && _playerController.requestedFromRotation && UIInterfaceOrientationIsPortrait(orientation))
        [_playerController dismissFullscreen:true duration:duration];
}

- (CGSize)_dimensions
{
    if (_webPage != nil)
        return [_webPage embedSize];
    else if (_document != nil)
        return [_document pictureSize];
    
    return CGSizeZero;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width screenHeight:(CGFloat)__unused screenHeight
{
    _smallActivated = fabs(screenHeight - _smallActivationHeight) < FLT_EPSILON;
    
    CGSize dimensions = [self _dimensions];
    CGSize embedSize = TGFitSize(CGSizeMake(dimensions.width, dimensions.height), CGSizeMake(width, CGFloor(width * 1.25f)));
    if (!CGSizeEqualToSize(embedSize, _embedSize))
    {
        _embedSize = embedSize;
        _playerView.frame = CGRectMake(_playerView.frame.origin.x, _playerView.frame.origin.y, embedSize.width, embedSize.height);
        _wrapperView.frame = CGRectMake(0, 0, embedSize.width, embedSize.height);
        _playerView.initialFrame = _playerView.frame;
        _placeholderView.frame = CGRectMake(0, 0, embedSize.width, embedSize.height);
    }
    
    return _embedSize.height;
}

- (CGFloat)contentHeightCorrection
{
    if (self.sizeClass == UIUserInterfaceSizeClassRegular)
        return 0.0f;
    
    return _smallActivated ? -57.0f : 0.0f;
}

- (void)layoutSubviews
{
    _wrapperView.frame = CGRectMake(0, 0, self.frame.size.width, _embedSize.height);
    
    if (_playerView.superview == _wrapperView)
        _playerView.center = CGPointMake(_wrapperView.frame.size.width / 2.0f, _wrapperView.frame.size.height / 2.0f);
}

@end
