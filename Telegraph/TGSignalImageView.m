#import "TGSignalImageView.h"

#import "TGModernGalleryTransitionView.h"

@interface TGSignalImageView () <TGModernGalleryTransitionView>
{
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGSignalImageView

- (void)willBecomeRecycled
{
    [self reset];
}

- (UIImage *)transitionImage
{
    return self.image;
}

- (CGRect)transitionContentRect
{
    return _transitionContentRect;
}

@end
