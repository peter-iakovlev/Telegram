#import "TGCollectionMenuController.h"

@interface TGChangePhoneNumberCodeController : TGCollectionMenuController

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber phoneCodeHash:(NSString *)phoneCodeHash callTimeout:(NSTimeInterval)callTimeout;

@end
