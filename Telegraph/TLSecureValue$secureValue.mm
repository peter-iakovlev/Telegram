#import "TLSecureValue$secureValue.h"

#import "TLMetaClassStore.h"

@implementation TLSecureValue$secureValue

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLSecureValue$secureValue serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLSecureValue$secureValue *result = [[TLSecureValue$secureValue alloc] init];
    
    result.flags = [is readInt32];
    
    {
        int32_t signature = [is readInt32];
        result.type = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    if (result.flags & (1 << 0)) {
        int32_t signature = [is readInt32];
        result.data = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    if (result.flags & (1 << 1)) {
        int32_t signature = [is readInt32];
        result.front_side = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    if (result.flags & (1 << 2)) {
        int32_t signature = [is readInt32];
        result.reverse_side = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    if (result.flags & (1 << 3)) {
        int32_t signature = [is readInt32];
        result.selfie = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    if (result.flags & (1 << 4)) {
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
        
        result.files = items;
    }
    
    if (result.flags & (1 << 5)) {
        int32_t signature = [is readInt32];
        result.plain_data = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    result.n_hash = [is readBytes];

    return result;
}

@end


