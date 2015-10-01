#import "TGSharedMediaAvailabilityState.h"

@implementation TGSharedMediaAvailabilityState

- (instancetype)initWithType:(TGSharedMediaAvailabilityStateType)type progress:(CGFloat)progress
{
    self = [super init];
    if (self != nil)
    {
        _type = type;
        _progress = progress;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGSharedMediaAvailabilityState class]] && _type == ((TGSharedMediaAvailabilityState *)object)->_type && ABS(_progress - ((TGSharedMediaAvailabilityState *)object)->_progress) < FLT_EPSILON;
}

@end
