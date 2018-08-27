#import <Foundation/Foundation.h>

@interface TGPassportLanguageMap : NSObject <NSCoding>

@property (nonatomic, readonly) NSDictionary *map;
@property (nonatomic, readonly) int32_t n_hash;

- (instancetype)initWithMap:(NSDictionary *)map hash:(int32_t)hash;

@end
