#import "TGWeakReference.h"

@implementation TGWeakReference

- (instancetype)initWithObject:(id)object
{
    self = [super init];
    if (self != nil)
    {
        self.object = object;
    }
    return self;
}

@end
