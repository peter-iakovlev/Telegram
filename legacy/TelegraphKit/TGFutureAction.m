#import "TGFutureAction.h"

@implementation TGFutureAction

- (id)initWithType:(int)type
{
    self = [super init];
    if (self != nil)
    {
        _type = type;
        
        _randomId = (int)lrand48();
    }
    return self;
}

- (NSData *)serialize
{
    TGAssert(false);
    
    return nil;
}

- (TGFutureAction *)deserialize:(NSData *)__unused data
{
    TGAssert(false);
    
    return nil;
}

- (void)prepareForDeletion
{
}

@end
