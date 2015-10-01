#import <Foundation/Foundation.h>

#import "PSCoding.h"

@interface TGMessageEntity : NSObject <PSCoding>

@property (nonatomic, readonly) NSRange range;

- (instancetype)initWithRange:(NSRange)range;

@end
