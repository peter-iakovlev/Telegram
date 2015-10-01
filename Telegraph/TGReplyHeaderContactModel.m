#import "TGReplyHeaderContactModel.h"

@implementation TGReplyHeaderContactModel

- (instancetype)initWithPeer:(id)peer incoming:(bool)incoming system:(bool)system
{
    self = [super initWithPeer:(id)peer incoming:incoming text:TGLocalized(@"Message.Contact") truncateTextInTheMiddle:false textColor:[TGReplyHeaderModel colorForMediaText:incoming] leftInset:0.0f system:system];
    if (self != nil)
    {
    }
    return self;
}

@end
