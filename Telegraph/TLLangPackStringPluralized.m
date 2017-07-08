#import "TLLangPackStringPluralized.h"

//langPackStringPluralized flags:# key:string zero_value:flags.0?string one_value:flags.1?string two_value:flags.2?string few_value:flags.3?string many_value:flags.4?string other_value:string = LangPackString;
//langPackStringPluralized flags:# key:string zero_value:flags.0?string one_value:flags.1?string two_value:flags.2?string few_value:flags.3?string many_value:flags.4?string other_value:string = LangPackString;


@implementation TLLangPackStringPluralized

- (void)TLserialize:(NSOutputStream *)__unused os
{
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLLangPackStringPluralized *result = [[TLLangPackStringPluralized alloc] init];

    int32_t flags = [is readInt32];
    result.flags = flags;
    
    result.key = [is readString];
    
    if (flags & (1 << 0)) {
        result.zero_value = [is readString];
    }
    
    if (flags & (1 << 1)) {
        result.one_value = [is readString];
    }
    
    if (flags & (1 << 2)) {
        result.two_value = [is readString];
    }
    
    if (flags & (1 << 3)) {
        result.few_value = [is readString];
    }
    
    if (flags & (1 << 4)) {
        result.many_value = [is readString];
    }
    
    result.other_value = [is readString];
    
    return result;
}


@end
