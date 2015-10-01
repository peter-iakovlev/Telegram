#import "TLDestroySessionsRes_manual.h"

@implementation TLDestroySessionsRes_manual

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(NSError *__autoreleasing *)error
{
    if (signature != (int32_t)0xfb95abcd)
    {
        if (error)
        {
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
            [userInfo setValue:[NSString stringWithFormat:@"Invalid signature %.8x (should be 0x73f1f8dc)", signature] forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:@"TL" code:-1 userInfo:userInfo];
        }
        
        return nil;
    }
    
    TLDestroySessionsRes *object = [[TLDestroySessionsRes alloc] init];
    
    
    
    return object;
}

@end
