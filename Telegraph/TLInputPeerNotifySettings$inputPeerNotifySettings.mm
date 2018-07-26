#import "TLInputPeerNotifySettings$inputPeerNotifySettings.h"

#import "TLMetaClassStore.h"

@implementation TLInputPeerNotifySettings$inputPeerNotifySettings

- (int32_t)TLconstructorSignature
{
    return 0x9c3d198e;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (void)TLserialize:(NSOutputStream *)__unused os
{
    [os writeInt32:self.flags];
    
    if (self.flags & (1 << 0)) {
        [os writeInt32:self.showPreviews ? TL_BOOL_TRUE_CONSTRUCTOR : TL_BOOL_FALSE_CONSTRUCTOR];
    }
    
    if (self.flags & (1 << 1)) {
        [os writeInt32:self.silent ? TL_BOOL_TRUE_CONSTRUCTOR : TL_BOOL_FALSE_CONSTRUCTOR];
    }
    
    if (self.flags & (1 << 2)) {
        [os writeInt32:self.mute_until];
    }
    
    if (self.flags & (1 << 3)) {
        [os writeString:self.sound];
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    return nil;
}

@end
