#import "TGAccountSetting.h"

@interface TGAccountTTLSetting : NSObject <TGAccountSetting>

@property (nonatomic, strong, readonly) NSNumber *accountTTL;

- (instancetype)initWithDefaultValues;
- (instancetype)initWithAccountTTL:(NSNumber *)accountTTL;

@end
