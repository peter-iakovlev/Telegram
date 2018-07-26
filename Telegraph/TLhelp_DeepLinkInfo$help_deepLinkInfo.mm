#import "TLhelp_DeepLinkInfo$help_deepLinkInfo.h"

#import "TLMetaClassStore.h"

@implementation TLhelp_DeepLinkInfo$help_deepLinkInfo

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLhelp_DeepLinkInfo$help_deepLinkInfo serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLhelp_DeepLinkInfo$help_deepLinkInfo *result = [[TLhelp_DeepLinkInfo$help_deepLinkInfo alloc] init];
    
    result.flags = [is readInt32];
    
    result.message = [is readString];
    
    if (result.flags & (1 << 0)) {
        [is readInt32];
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        int32_t count = [is readInt32];
        for (int32_t i = 0; i < count; i++) {
            int32_t signature = [is readInt32];
            id item = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (error != nil && *error != nil) {
                return nil;
            }
            if (item != nil) {
                [items addObject:item];
            }
        }
        
        result.entities = items;
    }
    
    return result;
}

@end
