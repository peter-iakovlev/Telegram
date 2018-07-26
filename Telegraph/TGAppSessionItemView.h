#import "TGEditableCollectionItemView.h"

@class TGAppSession;

@interface TGAppSessionItemView : TGEditableCollectionItemView

@property (nonatomic, copy) void (^removeRequested)();

- (void)setAppSession:(TGAppSession *)appSession;

@end

