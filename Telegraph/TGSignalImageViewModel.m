#import "TGSignalImageViewModel.h"

#import "TGSignalImageView.h"
#import "TGSignalImageViewWithProgress.h"

@interface TGSignalImageViewModel ()
{
    SSignal *(^_signalGenerator)();
    NSString *_identifier;
    CGFloat _progress;
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
    return _showProgress ? [TGSignalImageViewWithProgress class] : [TGSignalImageView class];
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
    
    if (_showProgress)
        ((TGSignalImageViewWithProgress *)self.boundView).progress = _progress;
    
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

@end
