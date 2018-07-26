#import "TLPeerNotifySettings$peerNotifySettings.h"

#import "TLMetaClassStore.h"

@implementation TLPeerNotifySettings$peerNotifySettings

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLPeerNotifySettings$peerNotifySettings serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLPeerNotifySettings$peerNotifySettings *result = [[TLPeerNotifySettings$peerNotifySettings alloc] init];
    
    result.flags = [is readInt32];
    
    if (result.flags & (1 << 0)) {
        result.showPreviews = [is readInt32] == TL_BOOL_TRUE_CONSTRUCTOR;
    }
    
    if (result.flags & (1 << 1)) {
        result.silent = [is readInt32] == TL_BOOL_TRUE_CONSTRUCTOR;
    }
    
    if (result.flags & (1 << 2)) {
        result.mute_until = [is readInt32];
    }
    
    if (result.flags & (1 << 3)) {
        result.sound = [is readString];
    }
    
    return result;
}

@end


