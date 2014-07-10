#import <Foundation/Foundation.h>

@protocol PSKeyValueReader <NSObject>

- (bool)readValueForRawKey:(const uint8_t *)key keyLength:(NSUInteger)keyLength value:(out uint8_t **)value valueLength:(out NSUInteger *)valueLength;

@end
