#import <Foundation/Foundation.h>

#import "PSCoding.h"

@interface TGMessageEntity : NSObject <PSCoding, NSCoding>

@property (nonatomic, readonly) NSRange range;

- (instancetype)initWithRange:(NSRange)range;

@end
