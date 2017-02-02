#import "TLInputMediaUploadedDocument.h"

#import "TLMetaClassStore.h"

//inputMediaUploadedDocument flags:# file:InputFile mime_type:string attributes:Vector<DocumentAttribute> caption:string stickers:flags.0?Vector<InputDocument> = InputMedia;

@implementation TLInputMediaUploadedDocument

- (int32_t)TLconstructorSignature
{
    return 0xd070f1e9;
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
    
    [os writeString:self.mime_type];
    
    {
        int32_t vectorSignature = TL_UNIVERSAL_VECTOR_CONSTRUCTOR;
        [os writeInt32:vectorSignature];
        
        [os writeInt32:(int32_t)self.attributes.count];
        for (TLDocumentAttribute *attribute in self.attributes) {
            TLMetaClassStore::serializeObject(os, attribute, true);
        }
    }
    
    [os writeString:self.caption];
    
    if ((self.flags & (1 << 0)) && self.stickers != nil) {
        int32_t vectorSignature = TL_UNIVERSAL_VECTOR_CONSTRUCTOR;
        [os writeInt32:vectorSignature];
        
        [os writeInt32:(int32_t)self.stickers.count];
        for (TLInputDocument *sticker in self.stickers) {
            TLMetaClassStore::serializeObject(os, sticker, true);
        }
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLInputMediaUploadedDocument *result = [[TLInputMediaUploadedDocument alloc] init];
    
    return result;
}

@end
