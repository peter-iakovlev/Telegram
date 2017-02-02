#import "TGDatabaseInterface.h"

#import "FMDatabase.h"

@interface TGDatabaseInterface () {
    NSString *_name;
    FMDatabase *_database;
}

@end

@implementation TGDatabaseInterface

- (instancetype)initWithName:(NSString *)name database:(FMDatabase *)database {
    self = [super init];
    if (self != nil) {
        _name = name;
        _database = database;
    }
    return self;
}

- (NSData *)get:(NSData *)key {
    if (key == nil) {
        return nil;
    }
    
    FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT value FROM %@ WHERE key=?", _name], key];
    if ([result next]) {
        return [result dataForColumnIndex:0];
    }
    
    return nil;
}

- (void)set:(NSData *)key value:(NSData *)value {
    if (key == nil) {
        return;
    }
    
    FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT rowid FROM %@ WHERE key=?", _name], key];
    if ([result next]) {
        [_database executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET value=?", _name], value];
    } else {
        [_database executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (key, value) VALUES (?, ?)", _name], key, value];
    }
}

- (void)remove:(NSData *)key {
    if (key != nil) {
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE key=?", _name], key];
    }
}

@end
