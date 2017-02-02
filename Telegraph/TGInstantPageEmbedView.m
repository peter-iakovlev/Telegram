#import "TGInstantPageEmbedView.h"

#import <WebKit/WebKit.h>

#import "TGImageUtils.h"
#import "TGSharedMediaUtils.h"
#import "TGSharedPhotoSignals.h"

#import "TGEmbedPlayerView.h"
#import "TGEmbedPlayerState.h"
#import "TGEmbedYoutubePlayerView.h"
#import "TGEmbedPlayerController.h"
#import "TGEmbedPIPController.h"
#import "TGEmbedPIPPlaceholderView.h"

@interface TGInstantPageEmbedView () <TGPIPAblePlayerContainerView> {
    UIView *_webView;
    
    __weak TGEmbedPlayerController *_playerController;
    __weak TGEmbedPIPPlaceholderView *_placeholderView;
    
    id (^_openEmbedFullscreen)(id, id);
    id (^_openEmbedPIP)(id, id, id, TGEmbedPIPCorner, id);
    bool _hadPIPPlayer;
}

@end

@implementation TGInstantPageEmbedView

- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url html:(NSString *)html posterMedia:(TGImageMediaAttachment *)posterMedia location:(TGPIPSourceLocation *)location enableScrolling:(bool)enableScrolling {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _url = url;
        _html = html;
        _posterMedia = posterMedia;
        _location = location;
        _enableScrolling = enableScrolling;
        
        if (iosMajorVersion() <= 8) {
            UIWebView *webView = [[UIWebView alloc] initWithFrame:self.bounds];
            webView.scalesPageToFit = true;
            webView.mediaPlaybackRequiresUserAction = false;
            webView.allowsInlineMediaPlayback = true;
            webView.scrollView.scrollEnabled = enableScrolling;
            
            [self addSubview:webView];
            
            if (html.length != 0) {
                [webView loadHTMLString:html baseURL:nil];
            } else {
                NSURL *parsedUrl = [NSURL URLWithString:url];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:parsedUrl];
                NSString *referer = [[NSString alloc] initWithFormat:@"%@://%@", [parsedUrl scheme], [parsedUrl host]];
                [request setValue:referer forHTTPHeaderField:@"Referer"];
                [webView loadRequest:request];
            }
            _webView = webView;
        } else {
            TGWebPageMediaAttachment *webPage = [[TGWebPageMediaAttachment alloc] init];
            webPage.embedUrl = url;
            
            Class playerViewClass = [TGEmbedPlayerView playerViewClassForWebPage:webPage onlySpecial:true];
            
            if (playerViewClass == [TGEmbedYoutubePlayerView class]) {
                bool hasPIPPlayer = [TGEmbedPIPController hasPictureInPictureActiveForLocation:_location playerView:NULL];
                _hadPIPPlayer = hasPIPPlayer;
                
                if (!hasPIPPlayer)
                {
                    SSignal *thumbnailSignal = nil;
                    if (posterMedia != nil)
                    {
                        CGSize fitSize = CGSizeMake(320.0f, 320.0f);
                        CGSize imageSize = TGFitSize(TGScaleToFill(frame.size, fitSize), fitSize);
                        
                        thumbnailSignal = [TGSharedPhotoSignals squarePhotoThumbnail:posterMedia ofSize:imageSize threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:nil downloadLargeImage:true placeholder:nil];
                    }
                    
                    TGEmbedPlayerView *playerView = [[playerViewClass alloc] initWithWebPageAttachment:webPage thumbnailSignal:thumbnailSignal];
                    playerView.frame = self.bounds;
                    playerView.disallowAutoplay = true;
                    playerView.roundCorners = 0;
                    [self addSubview:playerView];
                    
                    _webView = playerView;
                    
                    [self _configurePlayerView:playerView];
                    playerView.initialFrame = playerView.frame;
                    [playerView setupWithEmbedSize:self.bounds.size];
                }
                else
                {
                    TGEmbedPIPPlaceholderView *placeholderView = [[TGEmbedPIPPlaceholderView alloc] init];
                    _placeholderView = placeholderView;
                    _placeholderView.location = _location;
                    _placeholderView.containerView = self;
                    
                    __weak TGInstantPageEmbedView *weakSelf = self;
                    _placeholderView.onWillReattach = ^
                    {
                        __strong TGInstantPageEmbedView *strongSelf = weakSelf;
                        if (strongSelf == nil)
                            return;
                        
                        UIScrollView *scrollView = (UIScrollView *)strongSelf.superview;
                        if (![scrollView isKindOfClass:[UIScrollView class]])
                            return;
                        
                        [scrollView setContentOffset:scrollView.contentOffset animated:false];
                    };
                    [self addSubview:_placeholderView];
                    
                    [TGEmbedPIPController registerPlaceholderView:placeholderView];

                }
            }
            else {
                WKWebView *webView = [[WKWebView alloc] initWithFrame:self.bounds];
                webView.scrollView.scrollEnabled = enableScrolling;
                
                [self addSubview:webView];
                
                if (html.length != 0) {
                    [webView loadHTMLString:html baseURL:nil];
                } else {
                    NSURL *parsedUrl = [NSURL URLWithString:url];
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:parsedUrl];
                    NSString *referer = [[NSString alloc] initWithFormat:@"%@://%@", [parsedUrl scheme], [parsedUrl host]];
                    [request setValue:referer forHTTPHeaderField:@"Referer"];
                    [webView loadRequest:request];
                }
            }
        }
    }
    return self;
}

- (void)setIsVisible:(bool)__unused isVisible {
}

- (void)setOpenEmbedFullscreen:(id (^)(id, id))openEmbedFullscreen {
    _openEmbedFullscreen = [openEmbedFullscreen copy];
}

- (void)setOpenEmbedPIP:(id (^)(id, id, id, TGEmbedPIPCorner, id))openEmbedPIP {
    _openEmbedPIP = [openEmbedPIP copy];
}

- (void)_configurePlayerView:(TGEmbedPlayerView *)playerView
{
    __weak TGInstantPageEmbedView *weakSelf = self;
    __weak TGEmbedPlayerView *weakPlayerView = playerView;
    
    playerView.requestFullscreen = ^(__unused NSTimeInterval duration)
    {
        __strong TGInstantPageEmbedView *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (strongSelf->_openEmbedFullscreen) {
            strongSelf->_playerController = strongSelf->_openEmbedFullscreen(weakPlayerView, strongSelf);
        }
    };
    
    playerView.requestPictureInPicture = ^(TGEmbedPIPCorner corner)
    {
        __strong TGInstantPageEmbedView *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        __strong TGEmbedPlayerView *strongPlayerView = weakPlayerView;
        if (strongPlayerView == nil)
            return;
        
        if (strongSelf->_openEmbedPIP) {
            strongSelf->_placeholderView = strongSelf->_openEmbedPIP(weakPlayerView, strongSelf, strongSelf->_location, corner, strongSelf->_playerController);
        }
    };
    
    [TGEmbedPIPController registerPlayerView:playerView];
}

- (void)cancelPIP
{
    [_placeholderView setSolidColor];
    [TGEmbedPIPController cancelPictureInPictureWithOffset:CGPointZero];
}

- (void)reattachPlayerView
{
    _webView.frame = ((TGEmbedPlayerView *)_webView).initialFrame;
    [self addSubview:_webView];
}

- (void)reattachPlayerView:(TGEmbedPlayerView *)playerView
{
    [_placeholderView removeFromSuperview];
    _placeholderView = nil;
    
    _webView = playerView;
    [self reattachPlayerView];
    
    [self _configurePlayerView:playerView];
}

- (bool)shouldReattachPlayerBeforeTransition
{
    return false;
}

- (TGEmbedPIPPlaceholderView *)pipPlaceholderView
{
    return _placeholderView;
}

- (void)updateScreenPosition:(CGRect)screenPosition screenSize:(CGSize)screenSize
{
    if (_placeholderView != nil) {
        _placeholderView.invisible = screenPosition.origin.y > screenSize.height || screenPosition.origin.y < -self.frame.size.height;
        return;
    }
    
    if (![_webView isKindOfClass:[TGEmbedPlayerView class]])
        return;
    
    TGEmbedPlayerView *playerView = (TGEmbedPlayerView *)_webView;
    if (playerView.superview != self)
        return;
    
    if (playerView.state.isPlaying) {
        if (screenPosition.origin.y < -120.0f)
            [playerView enterPictureInPicture:TGEmbedPIPCornerTopRight];
        else if (screenPosition.origin.y > screenSize.height - 120.0f)
            [playerView enterPictureInPicture:TGEmbedPIPCornerBottomRight];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    if (!CGSizeEqualToSize(size, _webView.bounds.size)) {
        if (_webView.superview == self)
            _webView.frame = self.bounds;
        _placeholderView.frame = self.bounds;
    }
}

@end
