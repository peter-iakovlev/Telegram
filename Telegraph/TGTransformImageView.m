#import "TGTransformImageView.h"

@interface TGTransformImageView () {
    
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGTransformImageView

- (void)willBecomeRecycled {
    [self setSignal:[SSignal complete]];
}

- (UIImage *)transitionImage {
    id contents = self.layer.contents;
    if (contents != nil) {
        return [[UIImage alloc] initWithCGImage:(__bridge CGImageRef)(contents)];
    } else {
        return nil;
    }
}

@end
