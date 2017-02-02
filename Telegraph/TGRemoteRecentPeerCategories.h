#import <Foundation/Foundation.h>

@class TGRemoteRecentPeerSet;

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    TGPeerRatingCategoryNone = 0,
    TGPeerRatingCategoryPeople = 1,
    TGPeerRatingCategoryGroups = 2,
    TGPeerRatingCategoryBots = 4,
    TGPeerRatingCategoryInlineBots = 8
} TGPeerRatingCategory;

#ifdef __cplusplus
}
#endif

@interface TGRemoteRecentPeerCategories : NSObject

@property (nonatomic, readonly) NSTimeInterval lastRefreshTimestamp;
@property (nonatomic, strong, readonly) NSDictionary<NSNumber *, TGRemoteRecentPeerSet *> *categories;

- (instancetype)initWithLastRefreshTimestamp:(NSTimeInterval)lastRefreshTimestamp categories:(NSDictionary<NSNumber *, TGRemoteRecentPeerSet *> *)categories;

@end
