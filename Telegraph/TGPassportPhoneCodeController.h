#import "TGCollectionMenuController.h"
#import <SSignalKit/SSignalKit.h>

#import "TGPassportForm.h"

@interface TGPassportPhoneCodeController : TGCollectionMenuController

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber phoneCodeHash:(NSString *)phoneCodeHash callTimeout:(NSTimeInterval)callTimeout settings:(SVariable *)settings completionBlock:(void (^)(TGPassportDecryptedValue *))completionBlock;

@end
