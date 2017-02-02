#import "TGConfirmationCodeData.h"

@implementation TGConfirmationCodeData

- (instancetype)initWithCodeHash:(NSString *)codeHash timeout:(int32_t)timeout {
    self = [super init];
    if (self != nil) {
        _codeHash = codeHash;
        _timeout = timeout;
    }
    return self;
}

@end
