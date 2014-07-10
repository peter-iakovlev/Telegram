#import "TGActor.h"

#import "TGTelegraph.h"

@implementation TGActor

- (void)cancel
{
    if (self.cancelToken != nil)
    {
        [TGTelegraphInstance cancelRequestByToken:self.cancelToken];
        self.cancelToken = nil;
    }
    
    if (self.multipleCancelTokens != nil)
    {
        for (id token in self.multipleCancelTokens)
        {
            [TGTelegraphInstance cancelRequestByToken:token];
        }
        
        self.multipleCancelTokens = nil;
    }
    
    [super cancel];
}

@end
