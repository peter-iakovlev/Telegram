#import "TGViewController.h"

@class TGTwoStepConfig;

@interface TGLoginPasswordController : TGViewController

- (instancetype)initWithConfig:(TGTwoStepConfig *)config phoneNumber:(NSString *)phoneNumber phoneCode:(NSString *)phoneCode phoneCodeHash:(NSString *)phoneCodeHash;

@end
