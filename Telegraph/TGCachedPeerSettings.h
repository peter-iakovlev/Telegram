#import <Foundation/Foundation.h>

#import "PSCoding.h"

typedef enum {
    TGCachedPeerReportSpamUnknown = 0,
    TGCachedPeerReportSpamDismissed = 1,
    TGCachedPeerReportSpamShow = 2
} TGCachedPeerReportSpamState;

@interface TGCachedPeerSettings : NSObject <PSCoding>

@property (nonatomic, readonly) TGCachedPeerReportSpamState reportSpamState;

- (instancetype)initWithReportSpamState:(TGCachedPeerReportSpamState)reportSpamState;

- (TGCachedPeerSettings *)updateReportSpamState:(TGCachedPeerReportSpamState)reportSpamState;

@end
