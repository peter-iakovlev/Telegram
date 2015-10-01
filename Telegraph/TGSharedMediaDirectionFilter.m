#import "TGSharedMediaDirectionFilter.h"

@implementation TGSharedMediaDirectionFilter

- (instancetype)initWithDirection:(TGSharedMediaDirection)direction
{
    self = [super init];
    if (self != nil)
    {
        _direction = direction;
    }
    return self;
}

@end
