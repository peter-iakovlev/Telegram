#import "TGICloudEmergencyDataSignals.h"
#import <CloudKit/CloudKit.h>
#import <MTProtoKit/MTProtoKit.h>

#import "TGTelegraph.h"
#import "TGDatabase.h"
#import "TGTelegramNetworking.h"

@interface TGCloudKitDatacenterSubscription : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString *subscriptionId;
@property (nonatomic, strong, readonly) NSString *prefix;

@end

@implementation TGCloudKitDatacenterSubscription

- (instancetype)initWithSubscriptionId:(NSString *)subscriptionId prefix:(NSString *)prefix {
    self = [super init];
    if (self != nil) {
        _subscriptionId = subscriptionId;
        _prefix = prefix;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithSubscriptionId:[aDecoder decodeObjectForKey:@"subscriptionId"] prefix:[aDecoder decodeObjectForKey:@"prefix"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_subscriptionId forKey:@"subscriptionId"];
    [aCoder encodeObject:_prefix forKey:@"prefix"];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[TGCloudKitDatacenterSubscription class]]) {
        return false;
    }
    TGCloudKitDatacenterSubscription *other = (TGCloudKitDatacenterSubscription *)object;
    if (![_subscriptionId isEqual:other->_subscriptionId]) {
        return false;
    }
    if (![_prefix isEqual:other->_prefix]) {
        return false;
    }
    return true;
}

- (NSUInteger)hash {
    return [_subscriptionId hash];
}

@end

@interface TGICloudEmergencyDataInfo : NSObject

@property (nonatomic, strong, readonly) MTBackupDatacenterData *info;

@end

@implementation TGICloudEmergencyDataInfo

- (instancetype)initWithInfo:(MTBackupDatacenterData *)info {
    self = [super init];
    if (self != nil) {
        _info = info;
    }
    return self;
}

@end

@implementation TGICloudEmergencyDataSignals

+ (SVariable *)currentInfoByPrefix:(NSString *)prefix {
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = [[NSMutableDictionary alloc] init];
    });
    if (dict[prefix] == nil) {
        dict[prefix] = [[SVariable alloc] init];
    }
    return dict[prefix];
}

+ (SSignal *)fetchBackupAddressInfo:(NSString *)prefix phoneNumber:(NSString *)phoneNumber {
    return [[self currentInfoByPrefix:prefix].signal map:^id(NSData *data) {
        if (data.length != 0) {
            NSMutableData *finalData = [[NSMutableData alloc] initWithData:data];
            [finalData setLength:256];
            MTBackupDatacenterData *datacenterData = MTIPDataDecode(finalData, phoneNumber);
            if (datacenterData != nil) {
                return datacenterData;
            } else {
                return nil;
            }
        } else {
            return nil;
        }
    }];
}

+ (SSignal *)fetchBackupAddressInfoImpl:(NSString *)prefix {
    return [[[[[self fetchBackupAddressInfoOnce:prefix] mapToSignal:^SSignal *(MTBackupDatacenterData *result) {
        return [SSignal fail:result];
    }] catch:^SSignal *(id error) {
        if ([error respondsToSelector:@selector(boolValue)] && [error boolValue]) {
            return [[SSignal complete] delay:4.0 onQueue:[SQueue concurrentDefaultQueue]];
        } else {
            return [SSignal fail:error];
        }
    }] restart] catch:^SSignal *(id error) {
        if ([error isKindOfClass:[MTBackupDatacenterData class]]) {
            return [SSignal single:error];
        } else {
            return [SSignal complete];
        }
    }];
}
    
+ (SSignal *)fetchBackupAddressInfoOnce:(NSString *)prefix {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        if ([UIDevice.currentDevice.systemVersion floatValue] < 10) {
            [subscriber putError:@false];
            return [[SBlockDisposable alloc] initWithBlock:^{
            }];
        }
        @try {
            CKContainer *container = [CKContainer defaultContainer];
            CKDatabase *publicDatabase = [container databaseWithDatabaseScope:CKDatabaseScopePublic];
            if (publicDatabase != nil) {
                CKRecordID *recordId = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"emergency-datacenter-%@", prefix]];
                [publicDatabase fetchRecordWithID:recordId completionHandler:^(CKRecord *record, NSError *error) {
                    if (error) {
                        if ([error.domain isEqualToString:CKErrorDomain] && error.code == 1) {
                            [subscriber putError:@false];
                        } else {
                            //TGLog(@"[AddressInfo] fetchRecordWithID error: %@", [error description]);
                            [subscriber putError:@true];
                        }
                    } else {
                        NSString *text = [record objectForKey:@"data"];
                        if ([text respondsToSelector:@selector(characterAtIndex:)]) {
                            NSData *result = [[NSData alloc] initWithBase64EncodedString:text options:NSDataBase64DecodingIgnoreUnknownCharacters];
                            if (result != nil) {
                                NSMutableData *finalData = [[NSMutableData alloc] initWithData:result];
                                if (finalData.length != 0) {
                                    [finalData setLength:256];
                                    [subscriber putNext:finalData];
                                    [subscriber putCompletion];
                                }
                            }
                        }
                    }
                }];
            }
        } @catch(NSException *e) {
            //TGLog(@"[AddressInfo]", [e description]);
            [subscriber putError:@false];
        }
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }];
}

+ (SSignal *)deleteCloudKitSubscription:(NSString *)subscriptionId {
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        CKContainer *container = [CKContainer defaultContainer];
        CKDatabase *publicDatabase = [container databaseWithDatabaseScope:CKDatabaseScopePublic];
        if (publicDatabase != nil) {
            [publicDatabase deleteSubscriptionWithID:subscriptionId completionHandler:^(__unused NSString * subscriptionID, NSError *error) {
                if (error) {
                    TGLog(@"[TGICloudEmergencyDataSignals deleteSubscriptionWithID error %@]", [error description]);
                }
                [subscriber putCompletion];
            }];
        } else {
            [subscriber putCompletion];
        }
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]];
}

+ (SSignal *)fetchSubscriptionIds {
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        CKContainer *container = [CKContainer defaultContainer];
        CKDatabase *publicDatabase = [container databaseWithDatabaseScope:CKDatabaseScopePublic];
        if (publicDatabase != nil) {
            [publicDatabase fetchAllSubscriptionsWithCompletionHandler:^(NSArray<CKSubscription *> *subscriptions, NSError *error) {
                if (error) {
                    TGLog(@"[TGICloudEmergencyDataSignals fetchAllSubscriptionsWithCompletionHandler error %@]", [error description]);
                } else {
                    NSMutableArray *ids = [[NSMutableArray alloc] init];
                    for (CKSubscription *subscription in subscriptions) {
                        [ids addObject:subscription.subscriptionID];
                    }
                    [subscriber putNext:ids];
                }
                [subscriber putCompletion];
            }];
            return [[SBlockDisposable alloc] initWithBlock:^{
            }];
        } else {
            [subscriber putNext:@[]];
            [subscriber putCompletion];
            return nil;
        }
    }] startOn:[SQueue mainQueue]];
}

+ (SSignal *)deleteSubscriptionsExceptFor:(NSString *)keepId {
    return [[self fetchSubscriptionIds] mapToSignal:^SSignal *(NSArray *ids) {
        NSMutableArray *signals = [[NSMutableArray alloc] init];
        for (NSString *subscriptionId in ids) {
            if (![subscriptionId isEqualToString:keepId]) {
                [signals addObject:[self deleteCloudKitSubscription:subscriptionId]];
            }
        }
        if (signals.count == 0) {
            return [SSignal complete];
        }
        return [[SSignal mergeSignals:signals] mapToSignal:^SSignal *(__unused id next) {
            return [SSignal complete];
        }];
    }];
}

+ (SSignal *)updateSubscription {
    if ([UIDevice.currentDevice.systemVersion floatValue] < 10) {
        return [SSignal complete];
    }
    
    return [[TGDatabaseInstance() modify:^id{
        NSString *propertyKey = @"cloudkit-datacenter-subscription-v1";
        
        TGCloudKitDatacenterSubscription *currentSubscription = nil;
        NSData *data = [TGDatabaseInstance() customProperty:propertyKey];
        if (data != nil) {
            @try {
                TGCloudKitDatacenterSubscription *value = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                if ([value isKindOfClass:[TGCloudKitDatacenterSubscription class]]) {
                    currentSubscription = value;
                }
            } @catch(__unused NSException *e) {
            }
        }
        
        if (TGTelegraphInstance.clientUserId == 0) {
            if (currentSubscription != nil) {
                [TGDatabaseInstance() setCustomProperty:propertyKey value:nil];
                
                return [self deleteCloudKitSubscription:currentSubscription.subscriptionId];
            } else {
                return [SSignal complete];
            }
        }
        TGUser *user = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
        NSString *phone = [TGPhoneUtils cleanPhone:user.phoneNumber];
        
        if ([phone length] == 0) {
            if (currentSubscription != nil) {
                [TGDatabaseInstance() setCustomProperty:propertyKey value:nil];
                
                return [self deleteCloudKitSubscription:currentSubscription.subscriptionId];
            } else {
                return [SSignal complete];
            }
        }
        
        NSString *prefix = [phone substringToIndex:1];
        
        [[self currentInfoByPrefix:prefix] set:[self fetchBackupAddressInfoImpl:prefix]];
        
        if (currentSubscription != nil && [currentSubscription.prefix isEqualToString:prefix]) {
            return [SSignal complete];
        }
        
        SSignal *cleanup = [SSignal complete];
        
        if (currentSubscription != nil) {
            [TGDatabaseInstance() setCustomProperty:propertyKey value:nil];
        }
        
        cleanup = [self deleteSubscriptionsExceptFor:@""];
        
        return [cleanup then:[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
            CKRecordID *prefixRecordId = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"emergency-datacenter-%@", prefix]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recordID = %@", prefixRecordId];
            //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
            CKSubscription *subscription = [[CKSubscription alloc] initWithRecordType:@"EmergencyDatacenterInfo" predicate:predicate options:CKSubscriptionOptionsFiresOnRecordCreation | CKSubscriptionOptionsFiresOnRecordUpdate];
            CKNotificationInfo *notificationInfo = [CKNotificationInfo new];
            notificationInfo.desiredKeys = @[@"data"];
            notificationInfo.shouldSendContentAvailable = true;
            
            subscription.notificationInfo = notificationInfo;
            
            CKContainer *container = [CKContainer defaultContainer];
            CKDatabase *publicDatabase = [container databaseWithDatabaseScope:CKDatabaseScopePublic];
            if (publicDatabase != nil) {
                [publicDatabase saveSubscription:subscription completionHandler:^(CKSubscription *subscription, NSError *error) {
                    if (error) {
                        if ([error.description rangeOfString:@"subscription is duplicate of"].location != NSNotFound) {
                        } else {
                            TGLog(@"[TGICloudEmergencyDataSignals updateSubscription error %@]", [error description]);
                        }
                    } else {
                        NSData *updatedData = [NSKeyedArchiver archivedDataWithRootObject:[[TGCloudKitDatacenterSubscription alloc] initWithSubscriptionId:subscription.subscriptionID prefix:prefix]];
                        [TGDatabaseInstance() setCustomProperty:propertyKey value:updatedData];
                    }
                    [subscriber putCompletion];
                }];
            }
            
            return [[SBlockDisposable alloc] initWithBlock:^{
            }];
        }] startOn:[SQueue mainQueue]]];
    }] switchToLatest];
}

+ (void)processNotification:(CKNotification *)notification {
    if ([notification isKindOfClass:[CKQueryNotification class]]) {
        CKQueryNotification *queryNotification = (CKQueryNotification *)notification;
        NSString *namePrefix = @"emergency-datacenter-";
        NSString *recordName = queryNotification.recordID.recordName;
        if ([recordName hasPrefix:namePrefix]) {
            NSString *prefix = [recordName substringFromIndex:namePrefix.length];
            if (prefix.length != 0) {
                NSString *text = queryNotification.recordFields[@"data"];
                if ([text respondsToSelector:@selector(characterAtIndex:)]) {
                    NSData *result = [[NSData alloc] initWithBase64EncodedString:text options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    if (result != nil) {
                        NSMutableData *finalData = [[NSMutableData alloc] initWithData:result];
                        if (finalData.length != 0) {
                            [finalData setLength:256];
                            [[self currentInfoByPrefix:prefix] set:[SSignal single:finalData]];
                            
                            [[[TGTelegramNetworking instance] context] beginExplicitBackupAddressDiscovery];
                        }
                    }
                } else {
                    [[self currentInfoByPrefix:prefix] set:[self fetchBackupAddressInfoImpl:prefix]];
                }
            }
        }
    }
}

@end
