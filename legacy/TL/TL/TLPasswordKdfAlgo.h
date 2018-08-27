#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@interface TLPasswordKdfAlgo : NSObject <TLObject>

@end


@interface TLPasswordKdfAlgo$passwordKdfAlgoUnknown : TLPasswordKdfAlgo

@end

@interface TLPasswordKdfAlgo$passwordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow : TLPasswordKdfAlgo

@property (nonatomic, retain) NSData *salt1;
@property (nonatomic, retain) NSData *salt2;
@property (nonatomic) int32_t g;
@property (nonatomic, retain) NSData *p;

@end
