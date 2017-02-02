#import <Foundation/Foundation.h>

@class FMDatabase;

@interface TGDatabaseInterface : NSObject

- (instancetype)initWithName:(NSString *)name database:(FMDatabase *)database;

- (NSData *)get:(NSData *)key;
- (void)set:(NSData *)key value:(NSData *)value;
- (void)remove:(NSData *)key;

@end
