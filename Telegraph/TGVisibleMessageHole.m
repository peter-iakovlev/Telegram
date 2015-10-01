#import "TGVisibleMessageHole.h"

@implementation TGVisibleMessageHole

- (instancetype)initWithHole:(TGMessageHole *)hole direction:(TGVisibleMessageHoleDirection)direction {
    self = [super init];
    if (self != nil) {
        _hole = hole;
        _direction = direction;
    }
    return self;
}

@end
