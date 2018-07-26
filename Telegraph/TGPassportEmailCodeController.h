#import "TGCollectionMenuController.h"
#import <SSignalKit/SSignalKit.h>

#import "TGPassportForm.h"

@interface TGPassportEmailCodeController : TGCollectionMenuController

- (instancetype)initWithEmail:(NSString *)email settings:(SVariable *)settings completionBlock:(void (^)(TGPassportDecryptedValue *))completionBlock;

@end
