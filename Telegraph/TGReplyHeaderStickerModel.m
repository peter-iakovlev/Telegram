#import "TGReplyHeaderStickerModel.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGPresentation.h"

@implementation TGReplyHeaderStickerModel

- (instancetype)initWithPeer:(id)peer fileMedia:(TGDocumentMediaAttachment *)fileMedia incoming:(bool)incoming system:(bool)system presentation:(TGPresentation *)presentation
{
    __block NSString *stickerRepresentation = @"";
    
    for (id attribute in fileMedia.attributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
        {
            stickerRepresentation = ((TGDocumentAttributeSticker *)attribute).alt;
            break;
        }
    }
    
    self = [super initWithPeer:peer incoming:incoming text:stickerRepresentation == nil ? TGLocalized(@"Message.Sticker") : [[NSString alloc] initWithFormat:@"%@%@", stickerRepresentation, TGLocalized(@"Message.Sticker")] truncateTextInTheMiddle:true textColor:incoming ? presentation.pallete.chatIncomingSubtextColor : presentation.pallete.chatOutgoingSubtextColor leftInset:0.0f system:system presentation:presentation];
    if (self != nil)
    {
        
    }
    return self;
}

@end
