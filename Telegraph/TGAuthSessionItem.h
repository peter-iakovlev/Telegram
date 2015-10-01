#import "TGCollectionItem.h"

@class TGAuthSession;

@interface TGAuthSessionItem : TGCollectionItem

@property (nonatomic, strong, readonly) TGAuthSession *authSession;
@property (nonatomic, copy) void (^removeRequested)();

- (instancetype)initWithAuthSession:(TGAuthSession *)authSession removeRequested:(void (^)())removeRequested;

@end
