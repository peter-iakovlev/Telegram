#import <Foundation/Foundation.h>

@class TGPasswordKdfAlgo;
@class TGSecurePasswordKdfAlgo;
@class TLInputCheckPasswordSRP;

@interface TGTwoStepUtils : NSObject

+ (NSData *)SHA512:(NSData *)data;
+ (NSData *)PBKDF2HMACSHA512:(NSData *)data salt:(NSData *)salt;

+ (NSData *)passwordHashWithPassword:(NSString *)password algo:(TGPasswordKdfAlgo *)algo;
+ (NSData *)securePasswordHashWithPassword:(NSString *)password secureAlgo:(TGSecurePasswordKdfAlgo *)secureAlgo;

+ (NSData *)vWithX:(NSData *)x algo:(TGPasswordKdfAlgo *)algo;

+ (TLInputCheckPasswordSRP *)srpPasswordWithPassword:(NSString *)password algo:(TGPasswordKdfAlgo *)algo srpId:(int64_t)srpId srpB:(NSData *)srpB;
+ (TLInputCheckPasswordSRP *)srpPasswordWithPassword:(NSString *)password algo:(TGPasswordKdfAlgo *)algo srpId:(int64_t)srpId srpB:(NSData *)B outX:(NSData **)outX;
+ (TLInputCheckPasswordSRP *)srpPasswordWithX:(NSData *)x algo:(TGPasswordKdfAlgo *)algo srpId:(int64_t)srpId srpB:(NSData *)B;

@end
