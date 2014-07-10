#import <Foundation/Foundation.h>

@class TGDatabaseContext;
@class TGContactsContext;

@interface TGGlobalContext : NSObject

- (instancetype)initWithName:(NSString *)name;

- (NSString *)path;

- (TGDatabaseContext *)databaseContext;
- (TGContactsContext *)contactsContext;

@end
