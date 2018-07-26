#import "TLhelp_AppUpdate$help_appUpdate.h"

#import "TLMetaClassStore.h"

@implementation TLhelp_AppUpdate$help_appUpdate

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLhelp_AppUpdate$help_appUpdate serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLhelp_AppUpdate$help_appUpdate *result = [[TLhelp_AppUpdate$help_appUpdate alloc] init];
    
    result.flags = [is readInt32];
    result.n_id = [is readInt32];
    result.version = [is readString];
    result.text = [is readString];
    
    {
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
    
    {
        int32_t signature = [is readInt32];
        result.document = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    if (result.flags & (1 << 1)) {
        result.url = [is readString];
    }
    
    return result;
}

@end
