#import <Foundation/Foundation.h>

@interface TGPoolWithTimeout : NSObject

- (instancetype)initWithTimeout:(NSTimeInterval)timeout maxObjects:(NSUInteger)maxObjects;

- (void)addObject:(id)object;
- (id)takeObject;

@end
