#import "TLDocumentAttribute$documentAttributeAudio.h"

//documentAttributeAudio flags:# is_voice:flags.10?true duration:int title:flags.0?string performer:flags.1?string waveform:flags.2?bytes = DocumentAttribute;

@implementation TLDocumentAttribute$documentAttributeAudio

- (int32_t)TLconstructorSignature
{
    return 0x9852F9C6;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 46;
}

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:self.flags];
    
    [os writeInt32:self.duration];
    
    if (self.flags & (1 << 0)) {
        [os writeString:self.title];
    }
    if (self.flags & (1 << 1)) {
        [os writeString:self.performer];
    }
    if (self.flags & (1 << 2)) {
        [os writeBytes:self.waveform];
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLDocumentAttribute$documentAttributeAudio *result = [[TLDocumentAttribute$documentAttributeAudio alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    result.is_voice = flags & (1 << 10);
    
    result.duration = [is readInt32];
    
    if (flags & (1 << 0)) {
        result.title = [is readString];
    }
    if (flags & (1 << 1)) {
        result.performer = [is readString];
    }
    if (flags & (1 << 2)) {
        result.waveform = [is readBytes];
    }
    
    return result;
}


@end
