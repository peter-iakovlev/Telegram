#import "TGCollectionMenuController.h"

@interface TGPasswordEmailController : TGCollectionMenuController

@property (nonatomic, copy) void (^completion)(NSString *);

- (instancetype)initWithSkipEnabled:(bool)skipEnabled;

@end
