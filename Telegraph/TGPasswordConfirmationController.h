#import "TGCollectionMenuController.h"

@interface TGPasswordConfirmationController : TGCollectionMenuController

@property (nonatomic, copy) void (^changeEmail)();
@property (nonatomic, copy) void (^removePassword)();
@property (nonatomic, copy) void (^completion)();

- (instancetype)initWithEmail:(NSString *)email;

@end
