#import "TLhelp_TermsOfService$help_termsOfService.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"

@implementation TLhelp_TermsOfService$help_termsOfService

- (void)TLserialize:(NSOutputStream *)__unused os {
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error {
    TLhelp_TermsOfService$help_termsOfService *result = [[TLhelp_TermsOfService$help_termsOfService alloc] init];
    
    result.flags = [is readInt32];
    
    {
        int32_t signature = [is readInt32];
        result.n_id = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    result.text = [is readString];
    
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
        result.entities = items;
    }
    
    if (result.flags & (1 << 1) ) {
        result.min_age_confirm = [is readInt32];
    }
    
    return result;
}

@end
