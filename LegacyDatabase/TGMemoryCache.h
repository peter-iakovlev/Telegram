#import <Foundation/Foundation.h>

@interface TGMemoryCache : NSObject

- (void)setValue:(id)value forKey:(NSString *)key;
- (id)valueForKey:(NSString *)key;

@end
