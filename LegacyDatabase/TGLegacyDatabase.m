#import "TGLegacyDatabase.h"

#import "FMDatabase.h"

#import "TGLegacyUser.h"

@interface TGLegacyDatabase () {
    FMDatabase *_database;
    NSString *_databasePath;
}

@end

@implementation TGLegacyDatabase

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (self != nil) {
        _databasePath = path;
        
        [self _openDatabase];
    }
    return self;
}

- (bool)_isCurrentDatabaseEncrypted
{
    return [_databasePath hasSuffix:@".y"];
}

- (bool)_openDatabase {
    _database = [FMDatabase databaseWithPath:_databasePath];
    
    if (![_database open]) {
        NSLog(@"***** Error: couldn't open database! *****");
        [[[NSFileManager alloc] init] removeItemAtPath:_databasePath error:nil];
        return false;
    }
    
    [_database setShouldCacheStatements:true];
    [_database setLogsErrors:true];
    
    if ([self _isCurrentDatabaseEncrypted]) {
        return nil;
    }
    
    sqlite3_exec([_database sqliteHandle], "PRAGMA encoding=\"UTF-8\"", NULL, NULL, NULL);
    sqlite3_exec([_database sqliteHandle], "PRAGMA synchronous=NORMAL", NULL, NULL, NULL);
    sqlite3_exec([_database sqliteHandle], "PRAGMA journal_mode=TRUNCATE", NULL, NULL, NULL);
    
    return true;
}

- (NSArray<TGLegacyUser *> *)contactUsersMatchingQuery:(NSString *)query {
    NSString *normalizedQuery = [query lowercaseString];
    NSMutableArray<TGLegacyUser *> *users = [[NSMutableArray alloc] init];
    
    //FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT uid FROM contacts_v29"]];
    
    FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT uid, first_name, last_name, local_first_name, local_last_name, phone_number, access_hash FROM users_v29 WHERE uid IN (SELECT uid FROM contacts_v29)"]];
    while ([result next]) {
        int32_t uid = [result intForColumnIndex:0];
        NSString *firstName = [result stringForColumnIndex:1];
        NSString *lastName = [result stringForColumnIndex:2];
        NSString *phonebookFirstName = [result stringForColumnIndex:3];
        NSString *phonebookLastName = [result stringForColumnIndex:4];
        NSString *phoneNumber = [result stringForColumnIndex:5];
        int64_t accessHash = [result intForColumnIndex:6];
        
        NSString *normalizedFirstName = nil;
        NSString *normalizedLastName = nil;
        
        if (phonebookFirstName.length != 0 || phonebookLastName.length != 0) {
            normalizedFirstName = phonebookFirstName;
            normalizedLastName = phonebookLastName;
        } else {
            normalizedFirstName = firstName;
            normalizedLastName = lastName;
        }
        
        NSString *normalizedNameA = nil;
        NSString *normalizedNameB = nil;
        
        if (normalizedFirstName.length != 0 && normalizedLastName.length != 0) {
            normalizedNameA = [[[normalizedFirstName stringByAppendingString:@" "] stringByAppendingString:normalizedLastName] lowercaseString];
            normalizedNameB = [[[normalizedLastName stringByAppendingString:@" "] stringByAppendingString:normalizedFirstName] lowercaseString];
        } else if (normalizedFirstName.length != 0) {
            normalizedNameA = normalizedFirstName;
        } else if (normalizedLastName.length != 0) {
            normalizedNameA = normalizedLastName;
        } else {
            continue;
        }
        
        if ([normalizedNameA hasPrefix:normalizedQuery] || (normalizedNameB != nil && [normalizedNameB hasPrefix:normalizedQuery])) {
            [users addObject:[[TGLegacyUser alloc] initWithUserId:uid accessHash:accessHash firstName:normalizedFirstName lastName:normalizedLastName phoneNumber:phoneNumber]];
        }
    }
    
    return users;
}


+ (NSString *)cleanPhone:(NSString *)phone clip:(bool)clip
{
    if (phone.length == 0)
        return @"";
    
    char buf[phone.length];
    int bufPtr = 0;
    
    int length = (int)phone.length;
    for (int i = 0; i < length; i++)
    {
        unichar c = [phone characterAtIndex:i];
        if (c >= '0' && c <= '9')
        {
            buf[bufPtr++] = (char)c;
        }
    }
    
    if (bufPtr > 8) {
        return [[NSString alloc] initWithBytes:buf + bufPtr - 8 length:8 encoding:NSUTF8StringEncoding];
    } else {
        return [[NSString alloc] initWithBytes:buf length:bufPtr encoding:NSUTF8StringEncoding];
    }
}

- (NSArray<TGLegacyUser *> *)contactUsersMatchingPhone:(NSString *)queryPhoneNumber {
    NSString *normalizedPhone = [TGLegacyDatabase cleanPhone:queryPhoneNumber clip:true];
    NSMutableArray<TGLegacyUser *> *users = [[NSMutableArray alloc] init];
    
    FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT uid, first_name, last_name, local_first_name, local_last_name, phone_number, access_hash FROM users_v29 WHERE uid IN (SELECT uid FROM contacts_v29)"]];
    while ([result next]) {
        int32_t uid = [result intForColumnIndex:0];
        NSString *firstName = [result stringForColumnIndex:1];
        NSString *lastName = [result stringForColumnIndex:2];
        NSString *phonebookFirstName = [result stringForColumnIndex:3];
        NSString *phonebookLastName = [result stringForColumnIndex:4];
        NSString *phoneNumber = [result stringForColumnIndex:5];
        int64_t accessHash = [result intForColumnIndex:6];
        
        NSString *normalizedFirstName = nil;
        NSString *normalizedLastName = nil;
        
        if (phonebookFirstName.length != 0 || phonebookLastName.length != 0) {
            normalizedFirstName = phonebookFirstName;
            normalizedLastName = phonebookLastName;
        } else {
            normalizedFirstName = firstName;
            normalizedLastName = lastName;
        }
        
        if ([[TGLegacyDatabase cleanPhone:phoneNumber clip:true] isEqualToString:normalizedPhone]) {
            [users addObject:[[TGLegacyUser alloc] initWithUserId:uid accessHash:accessHash firstName:normalizedFirstName lastName:normalizedLastName phoneNumber:phoneNumber]];
            break;
        }
    }
    
    return users;
}

@end
