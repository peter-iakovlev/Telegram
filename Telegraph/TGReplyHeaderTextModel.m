#import "TGReplyHeaderTextModel.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGModernColorViewModel.h"
#import "TGModernTextViewModel.h"
#import "TGTelegraphConversationMessageAssetsSource.h"

#import <CoreText/CoreText.h>

#import "TGPresentation.h"

@interface TGReplyHeaderTextModel ()
{
}

@end

@implementation TGReplyHeaderTextModel

- (instancetype)initWithPeer:(id)peer text:(NSString *)text incoming:(bool)incoming system:(bool)system presentation:(TGPresentation *)presentation
{
    self = [super initWithPeer:peer incoming:incoming text:text truncateTextInTheMiddle:false textColor:incoming ? presentation.pallete.chatIncomingTextColor : presentation.pallete.chatOutgoingTextColor leftInset:0.0f system:system presentation:presentation];
    if (self != nil)
    {
    }
    return self;
}

@end
