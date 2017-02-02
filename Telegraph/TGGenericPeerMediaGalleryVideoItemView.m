#import "TGGenericPeerMediaGalleryVideoItemView.h"

#import "TGImageUtils.h"

#import "TGGenericPeerMediaGalleryVideoItem.h"
#import "TGModernGalleryVideoPlayerView.h"
#import "TGModernGalleryVideoScrubbingInterfaceView.h"

#import "TGDatabase.h"

#import "TGModernButton.h"
#import "TGModernGalleryZoomableScrollView.h"
#import "TGEmbedPIPPlaceholderView.h"
#import "TGEmbedPIPController.h"

@interface TGGenericPeerMediaGalleryVideoItemView ()
{
    TGEmbedPIPPlaceholderView *_placeholderView;
    TGPIPSourceLocation *_location;
}
@end

@implementation TGGenericPeerMediaGalleryVideoItemView

- (void)cancelPIP
{
    [_scrubbingInterfaceView setPictureInPictureHidden:false];
    
    _placeholderView.hidden = true;
    
    [TGEmbedPIPController cancelPictureInPictureWithOffset:CGPointMake(_placeholderView.frame.origin.x, _placeholderView.frame.origin.y)];
}

- (void)setItem:(id<TGModernGalleryItem>)item synchronously:(bool)synchronously
{
    TGGenericPeerMediaGalleryVideoItem *videoItem = (TGGenericPeerMediaGalleryVideoItem *)item;
    _location = [[TGPIPSourceLocation alloc] initWithEmbed:false peerId:videoItem.peerId messageId:videoItem.messageId localId:0 webPage:nil];
    
    [super setItem:item synchronously:synchronously];
    
    [self _configurePlayerView];
}

- (void)setFocused:(bool)isFocused
{
    if (!isFocused)
    {
        [super setFocused:isFocused];
    }
    else
    {
        TGModernGalleryVideoPlayerView *playerView = nil;
        if ([self _hasPIPPlayerView:&playerView])
        {
            if (playerView.state.isPlaying || playerView.state.position > DBL_EPSILON)
            {
                [self hidePlayButton];
                [super _willPlay];
            }
        }
    }
}

- (void)_willPlay
{
    [super _willPlay];
    
    if ([self.item isKindOfClass:[TGGenericPeerMediaGalleryVideoItem class]])
    {
        TGGenericPeerMediaGalleryVideoItem *item = (TGGenericPeerMediaGalleryVideoItem *)self.item;
        int messageId = item.messageId;
        if ([item.media isKindOfClass:[TGVideoMediaAttachment class]]) {
            [TGDatabaseInstance() updateLastUseDateForMediaType:1 mediaId:((TGVideoMediaAttachment *)item.media).videoId messageId:messageId];
        } else if ([item.media isKindOfClass:[TGDocumentMediaAttachment class]]) {
            [TGDatabaseInstance() updateLastUseDateForMediaType:3 mediaId:((TGDocumentMediaAttachment *)item.media).documentId messageId:messageId];
        }
    }
}

- (void)_configurePlayerView
{
    __weak TGGenericPeerMediaGalleryVideoItemView *weakSelf = self;
    
    [_scrubbingInterfaceView setPictureInPictureHidden:!_playerView.supportsPIP];
    
    _scrubbingInterfaceView.pipPressed = ^
    {
        __strong TGGenericPeerMediaGalleryVideoItemView *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_playerView switchToPictureInPicture];
    };
    
    _playerView.requestPictureInPicture = ^(TGEmbedPIPCorner corner)
    {
        __strong TGGenericPeerMediaGalleryVideoItemView *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (![strongSelf.item isKindOfClass:[TGGenericPeerMediaGalleryVideoItem class]])
              return;
        
        strongSelf->_playerViewDetached = true;
        
        [TGEmbedPIPController startPictureInPictureWithPlayerView:strongSelf->_playerView location:strongSelf->_location corner:corner onTransitionBegin:^
        {
            __strong TGModernGalleryNewVideoItemView *strongSelf = weakSelf;
            if (strongSelf != nil && [strongSelf.delegate respondsToSelector:@selector(itemViewDidRequestGalleryDismissal:animated:)])
                [strongSelf.delegate itemViewDidRequestGalleryDismissal:strongSelf animated:true];
        } onTransitionFinished:^
        {
        }];
    };
}

- (bool)_hasPIPPlayerView:(TGModernGalleryVideoPlayerView **)playerView
{
    return [TGEmbedPIPController hasPictureInPictureActiveForLocation:_location playerView:playerView];
}

- (void)_initializePlayerWithPath:(NSString *)videoPath duration:(NSTimeInterval)duration synchronously:(bool)synchronously
{
    TGModernGalleryVideoPlayerView *playerView = nil;
    bool hasPIPPlayer = [TGEmbedPIPController hasPictureInPictureActiveForLocation:_location playerView:&playerView];
    
    if (hasPIPPlayer)
    {
        [_playerView removeFromSuperview];
        _playerView = nil;
        
        TGEmbedPIPPlaceholderView *placeholderView = [[TGEmbedPIPPlaceholderView alloc] init];
        _placeholderView = placeholderView;
        _placeholderView.location = _location;
        _placeholderView.containerView = self;
        
        self.scrollView.userInteractionEnabled = false;
        [self addSubview:_placeholderView];
        
        [self updateInterface];
        [_scrubbingInterfaceView setDuration:playerView.state.duration currentTime:playerView.state.position isPlaying:playerView.state.isPlaying isPlayable:true animated:false];
        
        [TGEmbedPIPController registerPlaceholderView:placeholderView];
        
        [self _subscribeToStateOfPlayerView:playerView];
    }
    else
    {
        [super _initializePlayerWithPath:videoPath duration:duration synchronously:synchronously];
        
        if (_playerView != nil)
            [TGEmbedPIPController registerPlayerView:_playerView];
    }
}

- (UIView<TGPIPAblePlayerView> *)_playerView
{
    TGModernGalleryVideoPlayerView *playerView = nil;
    bool hasPIPPlayer = [TGEmbedPIPController hasPictureInPictureActiveForLocation:_location playerView:&playerView];
    
    if (hasPIPPlayer)
        return playerView;
    
    return [super _playerView];
}

- (TGEmbedPIPPlaceholderView *)pipPlaceholderView
{
    return _placeholderView;
}

- (void)reattachPlayerView:(UIView<TGPIPAblePlayerView> *)playerView
{
    [_placeholderView removeFromSuperview];
    _placeholderView = nil;
    
    _playerView = (TGModernGalleryVideoPlayerView *)playerView;
    self.scrollView.userInteractionEnabled = true;
    [self.scrollView addSubview:_playerView];
    
    [self _configurePlayerView];
    
    if (!_playerView.state.isPlaying)
        _actionButton.hidden = false;
    
    [self reset];
}

- (bool)shouldReattachPlayerBeforeTransition
{
    return true;
}

- (UIView *)transitionView
{
    if (_placeholderView != nil)
        return _placeholderView;
    
    return [super transitionView];
}

- (CGRect)transitionViewContentRect
{
    if (_placeholderView != nil)
        return _placeholderView.bounds;
    
    return [super transitionViewContentRect];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize videoSize = TGFitSize(TGFillSize(_videoDimensions, self.bounds.size), self.bounds.size);
    _placeholderView.frame = CGRectMake(floor((self.frame.size.width - videoSize.width) / 2.0f), floor((self.frame.size.height - videoSize.height) / 2.0f), videoSize.width, videoSize.height);
}

@end
