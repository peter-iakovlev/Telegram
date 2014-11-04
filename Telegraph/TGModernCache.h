#import <Foundation/Foundation.h>

@interface TGModernCache : NSObject

- (instancetype)initWithPath:(NSString *)path size:(NSUInteger)size;

- (void)setValue:(NSData *)value forKey:(NSData *)key;
- (void)getValueForKey:(NSData *)key completion:(void (^)(NSData *))completion;
- (NSData *)getValueForKey:(NSData *)key;
- (bool)containsValueForKey:(NSData *)key;

@end
