#import <Foundation/Foundation.h>

@interface TGConfirmationCodeData : NSObject

@property (nonatomic, strong, readonly) NSString *codeHash;
@property (nonatomic, readonly) int32_t timeout;

- (instancetype)initWithCodeHash:(NSString *)codeHash timeout:(int32_t)timeout;

@end
