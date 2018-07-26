#import "TLhelp_ProxyData.h"

#import "TLMetaClassStore.h"

@implementation TLhelp_ProxyData

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject {
    NSAssert(false, @"");
    return nil;
}

- (int32_t)TLconstructorName {
    return -1;
}

- (int32_t)TLconstructorSignature {
    return -1;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values {
    NSAssert(false, @"");
}

@end

@implementation TLhelp_ProxyData$proxyDataPromo

- (void)TLserialize:(NSOutputStream *)__unused os {
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error {
    TLhelp_ProxyData$proxyDataPromo *result = [[TLhelp_ProxyData$proxyDataPromo alloc] init];
    
    result.expires = [is readInt32];
    
    {
        int32_t signature = [is readInt32];
        result.peer = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    {
        __unused int32_t vectorSignature = [is readInt32];
        int32_t count = [is readInt32];
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (int32_t i = 0; i < count; i++)
        {
            int32_t signature = [is readInt32];
            id object = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (error != nil && *error != nil) {
                return nil;
            }
            if (object != nil)
            {
                [items addObject:object];
            }
        }
        result.chats = items;
    }
    
    {
        __unused int32_t vectorSignature = [is readInt32];
        int32_t count = [is readInt32];
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (int32_t i = 0; i < count; i++)
        {
            int32_t signature = [is readInt32];
            id object = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (error != nil && *error != nil) {
                return nil;
            }
            if (object != nil)
            {
                [items addObject:object];
            }
        }
        result.users = items;
    }
    
    return result;
}

@end

@implementation TLhelp_ProxyData$proxyDataEmpty

- (void)TLserialize:(NSOutputStream *)__unused os {
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error {
    TLhelp_ProxyData$proxyDataEmpty *result = [[TLhelp_ProxyData$proxyDataEmpty alloc] init];
    
    result.expires = [is readInt32];
    
    return result;
}

@end
