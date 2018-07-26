#import "TGReplyHeaderAudioModel.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGSharedVideoSignals.h"
#import "TGSharedMediaUtils.h"

#import "TGSignalImageViewModel.h"

#import "TGPresentation.h"

@implementation TGReplyHeaderAudioModel

- (instancetype)initWithPeer:(id)peer audioMedia:(TGAudioMediaAttachment *)__unused audioMedia incoming:(bool)incoming system:(bool)system presentation:(TGPresentation *)presentation
{
    self = [super initWithPeer:peer incoming:incoming text:TGLocalized(@"Message.Audio") truncateTextInTheMiddle:false textColor:incoming ? presentation.pallete.chatIncomingSubtextColor : presentation.pallete.chatOutgoingSubtextColor leftInset:0.0f system:system presentation:presentation];
    if (self != nil)
    {
        
    }
    return self;
}

@end
