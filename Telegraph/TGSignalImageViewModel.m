#import "TGSignalImageViewModel.h"

#import "TGSignalImageView.h"
#import "TGSignalImageViewWithProgress.h"

typedef enum {
    TGSignalImageViewModelOverlayNone = 0,
    TGSignalImageViewModelOverlayProgress,
    TGSignalImageViewModelOverlayDownload,
    TGSignalImageViewModelOverlayPlay
} TGSignalImageViewModelOverlay;

@interface TGSignalImageViewModel ()
{
    SSignal *(^_signalGenerator)();
    NSString *_identifier;
    CGFloat _progress;
    
    TGSignalImageViewModelOverlay _overlay;
}

@end

@implementation TGSignalImageViewModel

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _progress = -1.0f;
    }
    return self;
}

- (Class)viewClass
{
    return (_showProgress || _manualProgress) ? [TGSignalImageViewWithProgress class] : [TGSignalImageView class];
}

- (void)setSignalGenerator:(SSignal *(^)())signalGenerator identifier:(NSString *)identifier
{
    _signalGenerator = [signalGenerator copy];
    _identifier = identifier;
}

- (void)_updateViewStateIdentifier
{
    self.viewStateIdentifier = [[NSString alloc] initWithFormat:@"TGSignalImageView/%@", _identifier];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [self _updateViewStateIdentifier];
    
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    [((TGSignalImageView *)self.boundView) setInlineVideoInsets:_inlineVideoInsets];
    [((TGSignalImageView *)self.boundView) setInlineVideoSize:_inlineVideoSize];
    [((TGSignalImageView *)self.boundView) setInlineVideoCornerRadius:_inlineVideoCornerRadius];
    
    if (_manualProgress) {
        if ([[self boundView] isKindOfClass:[TGSignalImageViewWithProgress class]]) {
            ((TGSignalImageViewWithProgress *)self.boundView).manualProgress = _manualProgress;
            
            switch (_overlay) {
                case TGSignalImageViewModelOverlayProgress:
                    ((TGSignalImageViewWithProgress *)self.boundView).progress = _progress;
                    break;
                case TGSignalImageViewModelOverlayDownload:
                    [((TGSignalImageViewWithProgress *)self.boundView) setDownload];
                    break;
                case TGSignalImageViewModelOverlayNone:
                    [((TGSignalImageViewWithProgress *)self.boundView) setNone];
                    break;
                case TGSignalImageViewModelOverlayPlay:
                    [((TGSignalImageViewWithProgress *)self.boundView) setPlay];
                    break;
            }
        }
    } else {
        if (_showProgress)
            ((TGSignalImageViewWithProgress *)self.boundView).progress = _progress;
    }
    
    ((TGSignalImageView *)self.boundView).transitionContentRect = _transitionContentRect;
    
    if (_signalGenerator)
        [((TGSignalImageView *)self.boundView) setSignal:_signalGenerator()];
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    if (_showProgress)
        _progress = ((TGSignalImageViewWithProgress *)self.boundView).progress;
    
    [super unbindView:viewStorage];
}

- (void)setProgress:(float)progress animated:(bool)animated {
    _progress = progress;
    
    _overlay = TGSignalImageViewModelOverlayProgress;
    if ([[self boundView] isKindOfClass:[TGSignalImageViewWithProgress class]]) {
        [((TGSignalImageViewWithProgress *)self.boundView) setProgress:progress animated:animated];
    }
}

- (void)setDownload {
    _overlay = TGSignalImageViewModelOverlayDownload;
    if ([[self boundView] isKindOfClass:[TGSignalImageViewWithProgress class]]) {
        [((TGSignalImageViewWithProgress *)self.boundView) setDownload];
    }
}

- (void)setNone {
    _overlay = TGSignalImageViewModelOverlayNone;
    if ([[self boundView] isKindOfClass:[TGSignalImageViewWithProgress class]]) {
        [((TGSignalImageViewWithProgress *)self.boundView) setNone];
    }
}

- (void)setPlay {
    _overlay = TGSignalImageViewModelOverlayPlay;
    if ([[self boundView] isKindOfClass:[TGSignalImageViewWithProgress class]]) {
        [((TGSignalImageViewWithProgress *)self.boundView) setPlay];
    }
}

- (void)reload {
    if (_signalGenerator) {
        [((TGSignalImageView *)self.boundView) setSignal:_signalGenerator()];
    }
}

- (void)setVideoPathSignal:(SSignal *)videoPathSignal {
    [((TGSignalImageView *)self.boundView) setVideoPathSignal:videoPathSignal];
}

- (void)setInlineVideoInsets:(UIEdgeInsets)inlineVideoInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_inlineVideoInsets, inlineVideoInsets)) {
        _inlineVideoInsets = inlineVideoInsets;
        
        [((TGSignalImageView *)self.boundView) setInlineVideoInsets:_inlineVideoInsets];
    }
}

- (void)setInlineVideoCornerRadius:(CGFloat)inlineVideoCornerRadius {
    _inlineVideoCornerRadius = inlineVideoCornerRadius;
    [((TGSignalImageView *)self.boundView) setInlineVideoCornerRadius:_inlineVideoCornerRadius];
}

@end
