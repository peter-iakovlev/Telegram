#import <Foundation/Foundation.h>

@interface TGStoredTmpPassword : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, readonly) int32_t validUntil;

- (instancetype)initWithData:(NSData *)data validUntil:(int32_t)validUntil;

@end
