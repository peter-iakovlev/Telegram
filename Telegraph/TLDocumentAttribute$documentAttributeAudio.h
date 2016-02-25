#import "TLDocumentAttribute.h"

//documentAttributeAudio flags:# is_voice:flags.10?true duration:int title:flags.0?string performer:flags.1?string waveform:flags.2?bytes = DocumentAttribute;

@interface TLDocumentAttribute$documentAttributeAudio : TLDocumentAttribute

@property (nonatomic) int32_t flags;
@property (nonatomic) bool is_voice;
@property (nonatomic) int32_t duration;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *performer;
@property (nonatomic, strong) NSData *waveform;

@end
