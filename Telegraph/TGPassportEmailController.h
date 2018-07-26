#import "TGCollectionMenuController.h"

#import "TGPassportForm.h"

@interface TGPassportEmailController : TGCollectionMenuController

@property (nonatomic, strong) void (^completionBlock)(TGPassportDecryptedValue *);

- (instancetype)initWithSettings:(SVariable *)settings email:(NSString *)email;

@end
