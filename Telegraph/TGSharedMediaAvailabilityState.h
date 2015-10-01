#import <Foundation/Foundation.h>

typedef enum {
    TGSharedMediaAvailabilityStateAvailable,
    TGSharedMediaAvailabilityStateNotAvailable,
    TGSharedMediaAvailabilityStateDownloading
} TGSharedMediaAvailabilityStateType;

@interface TGSharedMediaAvailabilityState : NSObject

@property (nonatomic, readonly) TGSharedMediaAvailabilityStateType type;
@property (nonatomic, readonly) CGFloat progress;

- (instancetype)initWithType:(TGSharedMediaAvailabilityStateType)type progress:(CGFloat)progress;

@end
