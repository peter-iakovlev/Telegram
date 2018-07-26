#import "TGCollectionItem.h"

@class TGAppSession;

@interface TGAppSessionItem : TGCollectionItem

@property (nonatomic, strong, readonly) TGAppSession *appSession;
@property (nonatomic, copy) void (^removeRequested)();

- (instancetype)initWithAppSession:(TGAppSession *)appSession removeRequested:(void (^)())removeRequested;

@end
