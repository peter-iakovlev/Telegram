#import <Foundation/Foundation.h>

#import "PSKeyValueReader.h"
#import "PSKeyValueWriter.h"

@protocol PSKeyValueStore <NSObject>

- (void)readFromTable:(NSString *)name inTransaction:(void (^)(id<PSKeyValueReader>))transaction;
- (void)writeToTable:(NSString *)name inTransaction:(void (^)(id<PSKeyValueWriter>))transaction;

- (void)sync;

@end
