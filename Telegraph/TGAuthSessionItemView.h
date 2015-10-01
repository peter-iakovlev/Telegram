#import "TGEditableCollectionItemView.h"

@class TGAuthSession;

@interface TGAuthSessionItemView : TGEditableCollectionItemView

@property (nonatomic, copy) void (^removeRequested)();

- (void)setAuthSession:(TGAuthSession *)authSession;

@end
