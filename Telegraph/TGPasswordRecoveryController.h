#import "TGCollectionMenuController.h"

@interface TGPasswordRecoveryController : TGCollectionMenuController

@property (nonatomic, copy) void (^completion)(bool, int32_t);
@property (nonatomic, copy) void (^cancelled)();

- (instancetype)initWithEmailPattern:(NSString *)emailPattern;

@end
