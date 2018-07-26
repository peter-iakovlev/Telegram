#import "TLInputMediaUploadedDocument.h"

#import "TLMetaClassStore.h"

//inputMediaUploadedDocument flags:# file:InputFile thumb:flags.2?InputFile mime_type:string attributes:Vector<DocumentAttribute> caption:string stickers:flags.0?Vector<InputDocument> ttl_seconds:flags.1?int = InputMedia;

@implementation TLInputMediaUploadedDocument

- (int32_t)TLconstructorSignature
{
    return 0x5b38c6c1;
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
    
    if (self.flags & (1 << 2)) {
        TLMetaClassStore::serializeObject(os, self.thumb, true);
    }
    
    [os writeString:self.mime_type];
    
    {
        int32_t vectorSignature = TL_UNIVERSAL_VECTOR_CONSTRUCTOR;
        [os writeInt32:vectorSignature];
        
        [os writeInt32:(int32_t)self.attributes.count];
        for (TLDocumentAttribute *attribute in self.attributes) {
            TLMetaClassStore::serializeObject(os, attribute, true);
        }
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
    TLInputMediaUploadedDocument *result = [[TLInputMediaUploadedDocument alloc] init];
    
    return result;
}

@end


@implementation TLInputMediaDocument

- (int32_t)TLconstructorSignature
{
    return 0x23ab23d2;
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
    TLInputMediaDocument *result = [[TLInputMediaDocument alloc] init];
    
    return result;
}

@end

@implementation TLInputMediaDocumentExternal

- (int32_t)TLconstructorSignature
{
    return 0xfb52dc99;
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
    TLInputMediaDocumentExternal *result = [[TLInputMediaDocumentExternal alloc] init];
    
    return result;
}

@end
