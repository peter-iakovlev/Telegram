#import "TGChangePeerBlockStatusFutureAction.h"

@implementation TGChangePeerBlockStatusFutureAction

@synthesize block = _block;

- (id)initWithPeerId:(int64_t)peerId block:(bool)block
{
    self = [super initWithType:TGChangePeerBlockStatusFutureActionType];
    if (self != nil)
    {
        self.uniqueId = peerId;
        _block = block;
    }
    return self;
}

- (NSData *)serialize
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    int block = _block ? 1 : 0;
    [data appendBytes:&block length:4];
    
    return data;
}

- (TGFutureAction *)deserialize:(NSData *)data
{
    TGChangePeerBlockStatusFutureAction *action = nil;
    
    int ptr = 0;
    
    int block = 0;
    [data getBytes:&block range:NSMakeRange(ptr, 4)];
    ptr += 4;
    
    action = [[TGChangePeerBlockStatusFutureAction alloc] initWithPeerId:0 block:block != 0 ? true : false];
    
    return action;
}

@end
