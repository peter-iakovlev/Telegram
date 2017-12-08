#import "TGPresentation.h"
#import "TGDefaultPresentationPallete.h"

@implementation TGPresentation

static TGPresentation *currentPresentation;
static SPipe *presentationPipe;

- (instancetype)initWithPallete:(TGPresentationPallete *)pallete
{
    self = [super init];
    if (self != nil)
    {
        _pallete = pallete;
        _images = [TGPresentationImages imagesWithPallete:pallete];
    }
    return self;
}

+ (void)load
{
    presentationPipe = [[SPipe alloc] init];
    currentPresentation = [[TGPresentation alloc] initWithPallete:[[TGDefaultPresentationPallete alloc] init]];
}

+ (TGPresentation *)current
{
    return currentPresentation;
}

+ (SSignal *)signal
{
    return [[SSignal single:[self current]] then:presentationPipe.signalProducer()];
}

@end
