#import "TLInputSecureValue$inputSecureValue.h"

#import "TLMetaClassStore.h"

@implementation TLInputSecureValue$inputSecureValue

- (int32_t)TLconstructorSignature
{
    return 0x67872e8;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:self.flags];
    
    TLMetaClassStore::serializeObject(os, self.type, true);
    
    if (self.flags & (1 << 0)) {
        TLMetaClassStore::serializeObject(os, self.data, true);
    }
    
    if (self.flags & (1 << 1)) {
        TLMetaClassStore::serializeObject(os, self.front_side, true);
    }
    
    if (self.flags & (1 << 2)) {
        TLMetaClassStore::serializeObject(os, self.reverse_side, true);
    }
    
    if (self.flags & (1 << 3)) {
        TLMetaClassStore::serializeObject(os, self.selfie, true);
    }
    
    if (self.flags & (1 << 4)) {
        int32_t vectorSignature = TL_UNIVERSAL_VECTOR_CONSTRUCTOR;
        [os writeInt32:vectorSignature];
        
        [os writeInt32:(int32_t)self.files.count];
        for (TLInputSecureFile *file in self.files) {
            TLMetaClassStore::serializeObject(os, file, true);
        }
    }
    
    if (self.flags & (1 << 5)) {
        TLMetaClassStore::serializeObject(os, self.plain_data, true);
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLInputSecureValue$inputSecureValue deserialization not supported");
    return nil;
}

@end



