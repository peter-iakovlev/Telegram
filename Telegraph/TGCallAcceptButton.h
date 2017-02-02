#import "TGCallButton.h"

typedef enum
{
    TGCallAcceptButtonStateAccept,
    TGCallAcceptButtonStateEnd
} TGCallAcceptButtonState;

@interface TGCallAcceptButton : TGCallButton

- (void)setState:(TGCallAcceptButtonState)state;

+ (UIColor *)redColor;
+ (UIColor *)greenColor;

@end
