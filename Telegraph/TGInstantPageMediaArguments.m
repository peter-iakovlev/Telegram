#import "TGInstantPageMediaArguments.h"

@implementation TGInstantPageMediaArguments

- (instancetype)initWithInteractive:(bool)interactive {
    self = [super init];
    if (self != nil) {
        _interactive = interactive;
    }
    return self;
}

@end

@implementation TGInstantPageImageMediaArguments

- (instancetype)initWithInteractive:(bool)interactive roundCorners:(bool)roundCorners fit:(bool)fit {
    self = [super initWithInteractive:interactive];
    if (self != nil) {
        _roundCorners = roundCorners;
        _fit = fit;
    }
    return self;
}

@end

@implementation TGInstantPageVideoMediaArguments

- (instancetype)initWithInteractive:(bool)interactive autoplay:(bool)autoplay {
    self = [super initWithInteractive:interactive];
    if (self != nil) {
        _autoplay = autoplay;
    }
    return self;
}

@end
