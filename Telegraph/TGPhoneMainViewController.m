#import "TGPhoneMainViewController.h"

#import "TGGlobalContext.h"

@interface TGPhoneMainViewController ()
{
    TGGlobalContext *_globalContext;
}

@end

@implementation TGPhoneMainViewController

- (instancetype)initWithGlobalContext:(TGGlobalContext *)globalContext
{
    self = [super init];
    if (self != nil)
    {
        _globalContext = globalContext;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
}

@end
