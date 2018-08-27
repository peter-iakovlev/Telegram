#import <SSignalKit/SSignalKit.h>

@class TGPasswordKdfAlgo;
@class TGSecurePasswordKdfAlgo;

@interface TGTwoStepSetPaswordSignal : NSObject

+ (SSignal *)setPasswordWithCurrentAlgo:(TGPasswordKdfAlgo *)currentAlgo currentPassword:(NSString *)currentPassword currentSecret:(NSData *)currentSecret nextAlgo:(TGPasswordKdfAlgo *)nextAlgo nextPassword:(NSString *)nextPassword nextHint:(NSString *)nextHint email:(NSString *)email nextSecureAlgo:(TGSecurePasswordKdfAlgo *)nextSecureAlgo secureRandom:(NSData *)secureRandom srpId:(int64_t)srpId srpB:(NSData *)srpB;

+ (SSignal *)setPassword:(NSString *)password hint:(NSString *)hint email:(NSString *)email;
+ (SSignal *)setRecoveryEmail:(NSString *)recoveryEmail currentPassword:(NSString *)currentPassword algo:(TGPasswordKdfAlgo *)algo srpId:(int64_t)srpId srpB:(NSData *)srpB;

+ (SSignal *)setSecureSecret:(NSData *)secret nextSecureAlgo:(TGSecurePasswordKdfAlgo *)nextSecureAlgo currentPassword:(NSString *)currentPassword currentAlgo:(TGPasswordKdfAlgo *)currentAlgo recoveryEmail:(NSString *)recoveryEmail srpId:(int64_t)srpId srpB:(NSData *)srpB;

@end
