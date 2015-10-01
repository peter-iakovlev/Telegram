#import "TGSearchPeersSignals.h"

#import "TGGlobalMessageSearchSignals.h"

@implementation TGSearchPeersSignals

+ (SSignal *)searchPeersWithQuery:(NSString *)query
{
    return [TGGlobalMessageSearchSignals search:query includeMessages:false itemMapping:^id(id item)
    {
        return item;
    }];
}

@end
