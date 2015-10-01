#import "TGSharedMediaFilter.h"

typedef enum {
    TGSharedMediaDirectionBoth,
    TGSharedMediaDirectionIncoming,
    TGSharedMediaDirectionOutgoing
} TGSharedMediaDirection;

@interface TGSharedMediaDirectionFilter : NSObject <TGSharedMediaFilter>

@property (nonatomic, readonly) TGSharedMediaDirection direction;

- (instancetype)initWithDirection:(TGSharedMediaDirection)direction;

@end
