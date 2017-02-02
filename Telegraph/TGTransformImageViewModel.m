#import "TGTransformImageViewModel.h"

#import "TGTransformImageView.h"

@interface TGTransformImageViewModel () {
    SSignal *(^_signalGenerator)();
    NSString *_identifier;
}

@end

@implementation TGTransformImageViewModel

- (Class)viewClass {
    return [TGTransformImageView class];
}

- (void)setSignalGenerator:(SSignal *(^)())signalGenerator identifier:(NSString *)identifier {
    _signalGenerator = [signalGenerator copy];
    _identifier = identifier;
}

- (void)_updateViewStateIdentifier {
    self.viewStateIdentifier = [[NSString alloc] initWithFormat:@"TGTransformImageViewModel/%@", _identifier];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage {
    [self _updateViewStateIdentifier];
    
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    if (_signalGenerator) {
        [((TGTransformImageView *)self.boundView) setSignal:_signalGenerator()];
    }
    [((TGTransformImageView *)self.boundView) setArguments:_arguments];
}

- (void)unbindView:(TGModernViewStorage *)viewStorage {
    [super unbindView:viewStorage];
}

- (void)setArguments:(TransformImageArguments *)arguments {
    _arguments = arguments;
    
    [((TGTransformImageView *)self.boundView) setArguments:arguments];
}

@end
