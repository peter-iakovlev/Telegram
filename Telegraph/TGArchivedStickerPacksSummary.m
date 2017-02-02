#import "TGArchivedStickerPacksSummary.h"

@implementation TGArchivedStickerPacksSummary

- (instancetype)initWithCount:(NSUInteger)count {
    self = [super init];
    if (self != nil) {
        _count = count;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithCount:[aDecoder decodeIntegerForKey:@"count"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_count forKey:@"count"];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TGArchivedStickerPacksSummary class]] && ((TGArchivedStickerPacksSummary *)object)->_count == _count;
}

@end
