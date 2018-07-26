#import <SSignalKit/SSignalKit.h>

@interface TGTwoStepSetPaswordSignal : NSObject

+ (SSignal *)setPasswordWithCurrentSalt:(NSData *)currentSalt currentPassword:(NSString *)currentPassword currentSecret:(NSData *)currentSecret nextSalt:(NSData *)nextSalt nextPassword:(NSString *)nextPassword nextHint:(NSString *)nextHint email:(NSString *)email secretRandom:(NSData *)secretRandom nextSecureSalt:(NSData *)nextSecureSalt;
+ (SSignal *)setPassword:(NSString *)password hint:(NSString *)hint email:(NSString *)email;
+ (SSignal *)setRecoveryEmail:(NSData *)currentSalt currentPassword:(NSString *)currentPassword recoveryEmail:(NSString *)recoveryEmail;
+ (SSignal *)setSecureSecret:(NSData *)secret nextSecureSalt:(NSData *)nextSecureSalt currentSalt:(NSData *)currentSalt currentPassword:(NSString *)currentPassword recoveryEmail:(NSString *)recoveryEmail;

@end
