#import "TGReplyHeaderAudioModel.h"

#import "TGSharedVideoSignals.h"
#import "TGSharedMediaUtils.h"

#import "TGAudioMediaAttachment.h"

#import "TGSignalImageViewModel.h"

@implementation TGReplyHeaderAudioModel

- (instancetype)initWithPeer:(id)peer audioMedia:(TGAudioMediaAttachment *)__unused audioMedia incoming:(bool)incoming system:(bool)system
{
    self = [super initWithPeer:peer incoming:incoming text:TGLocalized(@"Message.Audio") truncateTextInTheMiddle:false textColor:[TGReplyHeaderModel colorForMediaText:incoming] leftInset:0.0f system:system];
    if (self != nil)
    {
        
    }
    return self;
}

@end
