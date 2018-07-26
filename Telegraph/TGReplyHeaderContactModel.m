#import "TGReplyHeaderContactModel.h"

#import "TGPresentation.h"

@implementation TGReplyHeaderContactModel

- (instancetype)initWithPeer:(id)peer incoming:(bool)incoming system:(bool)system presentation:(TGPresentation *)presentation
{
    self = [super initWithPeer:(id)peer incoming:incoming text:TGLocalized(@"Message.Contact") truncateTextInTheMiddle:false textColor:incoming ? presentation.pallete.chatIncomingSubtextColor : presentation.pallete.chatOutgoingSubtextColor leftInset:0.0f system:system presentation:presentation];
    if (self != nil)
    {
    }
    return self;
}

@end
