#import <Foundation/Foundation.h>

@class TLCdnPublicKey;

@interface TGCdnData : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString *publicKey;
    
- (instancetype)initWithPublicKey:(NSString *)publicKey;
- (instancetype)initWithDesc:(TLCdnPublicKey *)desc;

@end
