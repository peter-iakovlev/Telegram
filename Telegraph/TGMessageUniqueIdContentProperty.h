#import <Foundation/Foundation.h>

#import "PSCoding.h"

@interface TGMessageUniqueIdContentProperty : NSObject <PSCoding>

@property (nonatomic, readonly) int32_t value;

- (instancetype)initWithValue:(int32_t)value;

@end
