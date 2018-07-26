#import <Foundation/Foundation.h>

@interface TGTwoStepConfig : NSObject

@property (nonatomic, strong, readonly) NSData *nextSalt;
@property (nonatomic, strong, readonly) NSData *currentSalt;
@property (nonatomic, strong, readonly) NSData *secretRandom;
@property (nonatomic, strong, readonly) NSData *nextSecureSalt;
@property (nonatomic, readonly) bool hasRecovery;
@property (nonatomic, readonly) bool hasSecureValues;
@property (nonatomic, strong, readonly) NSString *currentHint;
@property (nonatomic, strong, readonly) NSString *unconfirmedEmailPattern;

- (instancetype)initWithNextSalt:(NSData *)nextSalt currentSalt:(NSData *)currentSalt secretRandom:(NSData *)secretRandom nextSecureSalt:(NSData *)nextSecureSalt hasRecovery:(bool)hasRecovery hasSecureValues:(bool)hasSecureValues currentHint:(NSString *)currentHint unconfirmedEmailPattern:(NSString *)unconfirmedEmailPattern;

@end


@interface TGPasswordSettings : NSObject

@property (nonatomic, strong, readonly) NSString *password;
@property (nonatomic, strong, readonly) NSString *email;
@property (nonatomic, strong, readonly) NSData *secret;
@property (nonatomic, readonly) int64_t secretHash;
@property (nonatomic, strong, readonly) NSData *secureSalt;

- (instancetype)initWithPassword:(NSString *)password email:(NSString *)email secret:(NSData *)secret secretHash:(int64_t)secretHash secureSalt:(NSData *)secureSalt;

@end
