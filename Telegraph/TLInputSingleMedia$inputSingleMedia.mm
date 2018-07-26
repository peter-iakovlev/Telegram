#import "TLInputSingleMedia$inputSingleMedia.h"

#import "TLMetaClassStore.h"

@implementation TLInputSingleMedia$inputSingleMedia

- (int32_t)TLconstructorSignature
{
    return 0x1cc6e91f;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (void)TLserialize:(NSOutputStream *)__unused os
{
    [os writeInt32:self.flags];
    
    TLMetaClassStore::serializeObject(os, self.media, true);
    
    [os writeInt64:self.random_id];
    
    [os writeString:self.message];
    
    if (self.flags & (1 << 0)) {
        int32_t vectorSignature = TL_UNIVERSAL_VECTOR_CONSTRUCTOR;
        [os writeInt32:vectorSignature];
        
        [os writeInt32:(int32_t)self.entities.count];
        for (TLMessageEntity *entity in self.entities) {
            TLMetaClassStore::serializeObject(os, entity, true);
        }
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    return nil;
}

@end
