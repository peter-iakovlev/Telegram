#import "TGFutureAction.h"

@implementation TGFutureAction

@synthesize uniqueId = _uniqueId;
@synthesize type = _type;
@synthesize randomId = _randomId;

- (id)initWithType:(int)type
{
    self = [super init];
    if (self != nil)
    {
        _type = type;
        
        _randomId = lrand48();
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
