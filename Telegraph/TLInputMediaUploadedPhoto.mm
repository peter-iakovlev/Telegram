#import "TLInputMediaUploadedPhoto.h"

#import "TLMetaClassStore.h"

@implementation TLInputMediaUploadedPhoto

- (int32_t)TLconstructorSignature
{
    return 0x1e287d04;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (void)TLserialize:(NSOutputStream *)__unused os
{
    [os writeInt32:self.flags];
    
    {
        TLMetaClassStore::serializeObject(os, self.file, true);
    }
    
    if ((self.flags & (1 << 0)) && self.stickers != nil) {
        int32_t vectorSignature = TL_UNIVERSAL_VECTOR_CONSTRUCTOR;
        [os writeInt32:vectorSignature];
        
        [os writeInt32:(int32_t)self.stickers.count];
        for (TLInputDocument *sticker in self.stickers) {
            TLMetaClassStore::serializeObject(os, sticker, true);
        }
    }
    
    if (self.flags & (1 << 1)) {
        [os writeInt32:self.ttl_seconds];
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLInputMediaUploadedPhoto *result = [[TLInputMediaUploadedPhoto alloc] init];
    
    return result;
}

@end


@implementation TLInputMediaPhoto

- (int32_t)TLconstructorSignature
{
    return 0xb3ba0635;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (void)TLserialize:(NSOutputStream *)__unused os
{
    [os writeInt32:self.flags];
    
    TLMetaClassStore::serializeObject(os, self.n_id, true);
    
    if (self.flags & (1 << 0)) {
        [os writeInt32:self.ttl_seconds];
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLInputMediaPhoto *result = [[TLInputMediaPhoto alloc] init];
    
    return result;
}

@end


@implementation TLInputMediaPhotoExternal

- (int32_t)TLconstructorSignature
{
    return 0xe5bbfe1a;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (void)TLserialize:(NSOutputStream *)__unused os
{
    [os writeInt32:self.flags];
    
    [os writeString:self.url];
    
    if (self.flags & (1 << 0)) {
        [os writeInt32:self.ttl_seconds];
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLInputMediaPhotoExternal *result = [[TLInputMediaPhotoExternal alloc] init];
    
    return result;
}

@end
