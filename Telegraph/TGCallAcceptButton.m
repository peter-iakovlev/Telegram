#import "TGCallAcceptButton.h"

const CGFloat TGCallAcceptButtonAcceptAngle = -2.35619f;

@interface TGCallAcceptButton ()
{
    TGCallAcceptButtonState _currentState;
}
@end

@implementation TGCallAcceptButton

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _currentState = TGCallAcceptButtonStateEnd;
        self.backColor = [TGCallAcceptButton redColor];
        self.titleLabel.alpha = 0.0f;
        [self setImage:[UIImage imageNamed:@"CallPhoneIcon"] forState:UIControlStateNormal];
    }
    return self;
}

- (void)setState:(TGCallAcceptButtonState)state
{
    if (state == _currentState)
        return;
    
    _currentState = state;
    
    switch (state) {
        case TGCallAcceptButtonStateAccept:
            self.backColor = [TGCallAcceptButton greenColor];
            self.iconRotation = TGCallAcceptButtonAcceptAngle;
            self.titleLabel.alpha = 1.0f;
            break;
            
        case TGCallAcceptButtonStateEnd:
            self.backColor = [TGCallAcceptButton redColor];
            self.iconRotation = 0.0f;
            self.titleLabel.alpha = 0.0f;
            break;
    }
}

+ (UIColor *)redColor
{
    return UIColorRGB(0xe33a32);
}

+ (UIColor *)greenColor
{
    return UIColorRGB(0x83de6b);
}

@end
