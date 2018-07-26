#import <Foundation/Foundation.h>
#import "TGPassportErrors.h"

@interface TGPassportFormRequest : NSObject

@property (nonatomic, readonly) int32_t botId;
@property (nonatomic, readonly, strong) NSString *scope;
@property (nonatomic, readonly, strong) NSArray *scopeValues;
@property (nonatomic, readonly, strong) NSString *publicKey;
@property (nonatomic, readonly, strong) NSString *bundleId;
@property (nonatomic, readonly, strong) NSString *callbackUrl;
@property (nonatomic, readonly, strong) NSString *origin;
@property (nonatomic, readonly, strong) NSString *payload;

- (instancetype)initWithBotId:(int32_t)botId scope:(NSString *)scope publicKey:(NSString *)publicKey bundleId:(NSString *)bundleId callbackUrl:(NSString *)callbackUrl payload:(NSString *)payload;

@end
