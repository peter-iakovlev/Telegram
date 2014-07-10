#import "TGUserStore.h"

#import "ATQueue.h"

#import "PSKeyValueEncoder.h"
#import "PSKeyValueDecoder.h"

#import "TGUserModel.h"
#import "TGMtFileLocation.h"

@interface TGUserStore ()
{
    id<PSKeyValueStore> _keyValueStore;
    ATQueue *_usersQueue;
}

@end

@implementation TGUserStore

- (instancetype)initWithKeyValueStore:(id<PSKeyValueStore>)keyValueStore
{
#ifdef DEBUG
    NSAssert(keyValueStore != nil, @"keyValueStore must not be nil");
#endif
    
    self = [super init];
    if (self != nil)
    {
        _keyValueStore = keyValueStore;
        _usersQueue = [[ATQueue alloc] init];
        
        /*[_usersQueue dispatchAfter:1.0 block:^
        {
            NSMutableArray *users = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < 10000; i++)
            {
                [users addObject:[[TGUserModel alloc] initWithUserId:i firstName:@"iuydtjsrfkyguhiji.uf" lastName:@"kjhgfjsdtjfhmvhjftd" avatarSmallLocation:[[TGMtFileLocation alloc] initWithVolumeId:1 localId:2 secret:3] avatarLargeLocation:nil]];
            }
            
            NSMutableArray *userData = [[NSMutableArray alloc] initWithCapacity:users.count];
            
            TG_TIMESTAMP_DEFINE(encode);
            
            for (TGUserModel *user in users)
            {
                PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
                [user encodeWithKeyValueCoder:encoder];
                [userData addObject:[encoder data]];
            }
            
            TG_TIMESTAMP_MEASURE(encode);
            
            TG_TIMESTAMP_DEFINE(decode);
            
            NSMutableArray *decodedUsers = [[NSMutableArray alloc] initWithCapacity:users.count];
            
            PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
            for (NSData *data in userData)
            {
                [decoder resetData:data];
                TGUserModel *user = [[TGUserModel alloc] initWithKeyValueCoder:decoder];
                [decodedUsers addObject:user];
            }
            
            TG_TIMESTAMP_MEASURE(decode);
            TGLog(@"end");
        }];*/
    }
    return self;
}

- (NSString *)tableName
{
    return @"users";
}

- (void)storeUsers:(NSArray *)users
{
    [_usersQueue dispatch:^
    {
        [_keyValueStore writeToTable:[self tableName] inTransaction:^(id<PSKeyValueWriter> writer)
        {
            PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
            
            for (TGUserModel *user in users)
            {
                NSData *uuidData = [[user uuid] bytes];
                
                [encoder reset];
                [user encodeWithKeyValueCoder:encoder];
                NSData *userData = [encoder data];
                
                [writer writeValueForRawKey:[uuidData bytes] keyLength:[uuidData length] value:userData.bytes valueLength:userData.length];
            }
        }];
    }];
}

- (TGUserModel *)userWithId:(int32_t)uid
{
    __block TGUserModel *result = nil;
    
    [_usersQueue dispatch:^
    {
        [_keyValueStore readFromTable:[self tableName] inTransaction:^(id<PSKeyValueReader> reader)
        {
            PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
            
            NSData *uuidData = [[[TGUserUUID alloc] initWithUserId:uid] bytes];
            
            uint8_t *value = NULL;
            NSUInteger valueLength = 0;
            
            if ([reader readValueForRawKey:[uuidData bytes] keyLength:uuidData.length value:&value valueLength:&valueLength] && value != NULL)
            {
                [decoder resetBytes:value length:valueLength];
                
                result = [[TGUserModel alloc] initWithKeyValueCoder:decoder];
            }
        }];
    } synchronous:true];
    
    return result;
}

- (NSMutableDictionary *)usersWithIds:(NSArray *)uids
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [_usersQueue dispatch:^
    {
        [_keyValueStore readFromTable:[self tableName] inTransaction:^(id<PSKeyValueReader> reader)
        {
            PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
            
            for (NSNumber *nUserId in uids)
            {
                NSData *uuidData = [[[TGUserUUID alloc] initWithUserId:(int32_t)[nUserId intValue]] bytes];
                
                uint8_t *value = NULL;
                NSUInteger valueLength = 0;
                
                if ([reader readValueForRawKey:[uuidData bytes] keyLength:uuidData.length value:&value valueLength:&valueLength] && value != NULL)
                {
                    [decoder resetBytes:value length:valueLength];
                    
                    TGUserModel *user = [[TGUserModel alloc] initWithKeyValueCoder:decoder];
                    if (user != nil)
                        dict[nUserId] = user;
                }
            }
        }];
    } synchronous:true];
    
    return dict;
}

- (void)storeUserPresences:(NSArray *)userPresences
{
    
}

- (TGUserPresenceModel *)userPresenceWithId:(int32_t)uid
{
    return nil;
}

- (NSMutableDictionary *)userPresencesWithIds:(NSArray *)uids
{
    return nil;
}

@end
