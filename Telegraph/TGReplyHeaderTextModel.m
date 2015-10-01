#import "TGReplyHeaderTextModel.h"

#import "TGModernColorViewModel.h"
#import "TGModernTextViewModel.h"
#import "TGTelegraphConversationMessageAssetsSource.h"

#import <CoreText/CoreText.h>

#import "TGUser.h"

@interface TGReplyHeaderTextModel ()
{
}

@end

@implementation TGReplyHeaderTextModel

- (instancetype)initWithPeer:(id)peer text:(NSString *)text incoming:(bool)incoming system:(bool)system
{
    self = [super initWithPeer:peer incoming:incoming text:text truncateTextInTheMiddle:false textColor:[UIColor blackColor] leftInset:0.0f system:system];
    if (self != nil)
    {
    }
    return self;
}

@end
