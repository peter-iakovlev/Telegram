#import <LegacyComponents/LegacyComponents.h>

@interface TGHashtagOverviewController : TGNavigationController

@property (nonatomic, readonly) NSString *query;

- (instancetype)initWithQuery:(NSString *)query peerId:(int64_t)peerId;

- (void)setQuery:(NSString *)query peerId:(int64_t)peerId;

@end
