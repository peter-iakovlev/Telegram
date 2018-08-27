#import "TGTwoStepUtils.h"

#import <LegacyComponents/TGStringUtils.h>
#import <CommonCrypto/CommonCrypto.h>
#import <MTProtoKit/MTEncryption.h>
#import <MTProtoKit/MTFileBasedKeychain.h>

#import "TGAppDelegate.h"

#import "TLMetaScheme.h"

#import "TGTwoStepConfig.h"

@implementation TGTwoStepUtils

+ (NSData *)SHA512:(NSData *)data
{
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, (CC_LONG)data.length, digest);
    
    return [[NSData alloc] initWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];
}

+ (NSData *)PBKDF2HMACSHA512:(NSData *)data salt:(NSData *)salt
{
    const size_t len = 64;
    const size_t rounds = 100000;
    
    NSMutableData *key = [[NSMutableData alloc] initWithBytesNoCopy:malloc(len) length:len freeWhenDone:true];
    
    int result = CCKeyDerivationPBKDF(kCCPBKDF2, data.bytes, data.length, salt.bytes, salt.length, kCCPRFHmacAlgSHA512, rounds, key.mutableBytes, len);
    if (result != kCCSuccess)
        return nil;
    
    return key;
}

+ (NSData *)securePasswordHashWithPassword:(NSString *)password secureAlgo:(TGSecurePasswordKdfAlgo *)secureAlgo
{
    NSData *passwordHash = nil;
    if ([secureAlgo isKindOfClass:[TGSecurePasswordKdfAlgoPBKDF2HMACSHA512iter100000 class]])
    {
        TGSecurePasswordKdfAlgoPBKDF2HMACSHA512iter100000 *concreteAlgo = (TGSecurePasswordKdfAlgoPBKDF2HMACSHA512iter100000 *)secureAlgo;
        
        passwordHash = [self PBKDF2HMACSHA512:[password dataUsingEncoding:NSUTF8StringEncoding] salt:concreteAlgo.salt];
    }
    else if ([secureAlgo isKindOfClass:[TGSecurePasswordKdfAlgoSHA512 class]])
    {
        TGSecurePasswordKdfAlgoSHA512 *concreteAlgo = (TGSecurePasswordKdfAlgoSHA512 *)secureAlgo;
        
        NSMutableData *passwordHashData = [[NSMutableData alloc] init];
        [passwordHashData appendData:concreteAlgo.salt];
        [passwordHashData appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];
        [passwordHashData appendData:concreteAlgo.salt];
        
        passwordHash = [TGTwoStepUtils SHA512:passwordHashData];
    }
    return passwordHash;
}

+ (NSData *)xWithPassword:(NSString *)password algo:(TGPasswordKdfAlgo *)algo
{
    if ([algo isKindOfClass:[TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow class]])
    {
        TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow *concreteAlgo = (TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow *)algo;
        NSData *salt1 = concreteAlgo.salt1;
        NSData *salt2 = concreteAlgo.salt2;
        
        NSMutableData *data = [[NSMutableData alloc] init];
        [data appendData:salt1];
        [data appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:salt1];
        NSData *hash1 = MTSha256(data);
        
        data = [[NSMutableData alloc] init];
        [data appendData:salt2];
        [data appendData:hash1];
        [data appendData:salt2];
        NSData *hash2 = MTSha256(data);
        
        data = [[NSMutableData alloc] init];
        [data appendData:salt2];
        [data appendData:[self PBKDF2HMACSHA512:hash2 salt:salt1]];
        [data appendData:salt2];
        return MTSha256(data);
    }
    return nil;
}

+ (NSData *)passwordHashWithPassword:(NSString *)password algo:(TGPasswordKdfAlgo *)algo
{
    NSData *x = [self xWithPassword:password algo:algo];
    return [self vWithX:x algo:algo];
}

+ (NSData *)vWithX:(NSData *)x algo:(TGPasswordKdfAlgo *)algo
{
    if (x == nil)
        return nil;
    
    if ([algo isKindOfClass:[TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow class]])
    {
        TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow *concreteAlgo = (TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow *)algo;
        int32_t tmpG = NSSwapInt(concreteAlgo.g);
        NSData *g = [[NSData alloc] initWithBytes:&tmpG length:4];
        NSData *p = concreteAlgo.p;
        
        NSData *v = MTExp(g, x, p);
        return v;
    }
    
    return nil;
}

+ (NSData *)paddedData:(NSData *)data
{
    if (data.length < 256)
    {
        NSUInteger bytesToAdd = 256 - data.length;
        NSMutableData *paddedData = [[NSMutableData alloc] init];
        uint8_t zeros[bytesToAdd];
        memset(zeros, 0, bytesToAdd);

        [paddedData appendBytes:zeros length:bytesToAdd];
        [paddedData appendData:data];
        return paddedData;
    }
    return data;
}

+ (TLInputCheckPasswordSRP *)srpPasswordWithPassword:(NSString *)password algo:(TGPasswordKdfAlgo *)algo srpId:(int64_t)srpId srpB:(NSData *)B
{
    return [self srpPasswordWithPassword:password algo:algo srpId:srpId srpB:B outX:NULL];
}

+ (TLInputCheckPasswordSRP *)srpPasswordWithPassword:(NSString *)password algo:(TGPasswordKdfAlgo *)algo srpId:(int64_t)srpId srpB:(NSData *)B outX:(NSData **)outX
{
    if (password.length == 0)
        return [[TLInputCheckPasswordSRP$inputCheckPasswordEmpty alloc] init];
    
    NSData *x = [self xWithPassword:password algo:algo];
    if (outX != NULL)
        *outX = x;
    
    return [self srpPasswordWithX:x algo:algo srpId:srpId srpB:B];
}

+ (TLInputCheckPasswordSRP *)srpPasswordWithX:(NSData *)x algo:(TGPasswordKdfAlgo *)algo srpId:(int64_t)srpId srpB:(NSData *)B
{
    if ([algo isKindOfClass:[TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow class]])
    {
        TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow *concreteAlgo = (TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow *)algo;
        NSData *p = concreteAlgo.p;
        NSData *salt1 = concreteAlgo.salt1;
        NSData *salt2 = concreteAlgo.salt2;
        
        if (!MTCheckIsSafeG(concreteAlgo.g))
            return nil;
        
        if (!MTCheckMod(p, concreteAlgo.g, [MTFileBasedKeychain keychainWithName:@"legacyPrimes" documentsPath:[TGAppDelegate documentsPath]]))
            return nil;
        
        int32_t tmpG = NSSwapInt(concreteAlgo.g);
        NSData *g = [[NSData alloc] initWithBytes:&tmpG length:4];
        NSData *gBytes = [self paddedData:g];
        
        if (!MTCheckIsSafeB(B, p))
            return nil;
        
        NSMutableData *kData = [[NSMutableData alloc] init];
        [kData appendData:p];
        [kData appendData:gBytes];
        NSData *k = MTSha256(kData);
    
        uint8_t aBytes[256];
        __unused int result = SecRandomCopyBytes(kSecRandomDefault, 256, aBytes);
        NSData *a = [[NSData alloc] initWithBytes:aBytes length:256];
        
        NSData *A = MTExp(g, a, p);
        NSData *ABytes = [self paddedData:A];
        NSData *BBytes = [self paddedData:B];
        
        NSMutableData *uData = [[NSMutableData alloc] init];
        [uData appendData:ABytes];
        [uData appendData:BBytes];
        NSData *u = MTSha256(uData);
        if (MTIsZero(u))
            return nil;
        
        NSData *gx = MTExp(g, x, p);
        NSData *s1 = MTModSub(B, MTModMul(k, gx, p), p);
        if (!MTCheckIsSafeGAOrB(s1, p))
            return nil;
        
        NSData *s2 = MTAdd(a, MTMul(u, x));
        NSData *S = MTExp(s1, s2, p);
        
        NSData *K = MTSha256([self paddedData:S]);
        
        NSData *pH = MTSha256(p);
        NSData *gH = MTSha256(gBytes);
        
        NSMutableData *pHgHXor = [[NSMutableData alloc] initWithLength:pH.length];
        uint8_t *pHgHXorBytes = (uint8_t *)pHgHXor.mutableBytes;
        for (NSUInteger i = 0; i < pHgHXor.length; i++) {
            uint8_t pHByte = ((uint8_t *)pH.bytes)[i];
            uint8_t gHByte = ((uint8_t *)gH.bytes)[i];
            *(pHgHXorBytes + i) = (uint8_t)(gHByte ^ pHByte);
        }
                
        NSMutableData *MData = [[NSMutableData alloc] init];
        [MData appendData:pHgHXor];
        [MData appendData:MTSha256(salt1)];
        [MData appendData:MTSha256(salt2)];
        [MData appendData:ABytes];
        [MData appendData:BBytes];
        [MData appendData:K];
        NSData *M = MTSha256(MData);
        
        TLInputCheckPasswordSRP$inputCheckPasswordSRP *inputCheckPasswordSRP = [[TLInputCheckPasswordSRP$inputCheckPasswordSRP alloc] init];
        inputCheckPasswordSRP.srp_id = srpId;
        inputCheckPasswordSRP.A = ABytes;
        inputCheckPasswordSRP.M1 = M;
        return inputCheckPasswordSRP;
    }
    
    return nil;
}

@end
