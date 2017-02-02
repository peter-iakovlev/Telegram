#import "TLInputMediaUploadedPhoto.h"

#import "TLMetaClassStore.h"

//inputMediaUploadedPhoto flags:# file:InputFile caption:string stickers:flags.0?Vector<InputDocument> = InputMedia

@implementation TLInputMediaUploadedPhoto

- (int32_t)TLconstructorSignature
{
    return 0x630c9af1;
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
    TLInputMediaUploadedPhoto *result = [[TLInputMediaUploadedPhoto alloc] init];
    
    return result;
}

@end
