#import "TLDocumentAttributeSticker.h"

#import "TLMetaClassStore.h"

//documentAttributeSticker#6319d612 flags:# alt:string stickerset:InputStickerSet mask_coords:flags.0?MaskCoords = DocumentAttribute;

@implementation TLDocumentAttributeSticker

- (int32_t)TLconstructorSignature
{
    return 0x6319d612;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (void)TLserialize:(NSOutputStream *)__unused os
{
    [os writeInt32:self.flags];
    [os writeString:self.alt];
    
    TLMetaClassStore::serializeObject(os, self.stickerset, true);
    
    if (self.flags & (1 << 0) && self.mask_coords != nil) {
        TLMetaClassStore::serializeObject(os, self.mask_coords, true);
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLDocumentAttributeSticker *result = [[TLDocumentAttributeSticker alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    result.alt = [is readString];
    
    {
        int32_t signature = [is readInt32];
        result.stickerset = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    if (flags & (1 << 0))
    {
        int32_t signature = [is readInt32];
        result.mask_coords = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    return result;
}

@end
