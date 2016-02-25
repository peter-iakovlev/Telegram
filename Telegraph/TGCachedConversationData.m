#import "TGCachedConversationData.h"

#import "PSKeyValueCoder.h"

@implementation TGCachedConversationMember

- (instancetype)initWithUid:(int32_t)uid role:(TGChannelRole)role timestamp:(int32_t)timestamp {
    self = [super init];
    if (self != nil) {
        _uid = uid;
        _role = role;
        _timestamp = timestamp;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder {
    return [self initWithUid:[coder decodeInt32ForCKey:"i"] role:[coder decodeInt32ForCKey:"r"] timestamp:[coder decodeInt32ForCKey:"t"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder {
    [coder encodeInt32:_uid forCKey:"i"];
    [coder encodeInt32:_role forCKey:"r"];
    [coder encodeInt32:_timestamp forCKey:"t"];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TGCachedConversationMember class]] && ((TGCachedConversationMember *)object)->_uid == _uid;
}

@end

@implementation TGConversationMigrationData

- (instancetype)initWithPeerId:(int64_t)peerId maxMessageId:(int32_t)maxMessageId {
    self = [super init];
    if (self != nil) {
        _peerId = peerId;
        _maxMessageId = maxMessageId;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder {
    return [self initWithPeerId:[coder decodeInt64ForCKey:"peerId"] maxMessageId:[coder decodeInt32ForCKey:"maxMessageId"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder {
    [coder encodeInt64:_peerId forCKey:"peerId"];
    [coder encodeInt32:_maxMessageId forCKey:"maxMessageId"];
}

@end

@implementation TGCachedConversationData

- (instancetype)init {
    self = [super init];
    if (self != nil) {
    }
    return self;
}

- (instancetype)initWithManagementCount:(int32_t)managementCount blacklistCount:(int32_t)blacklistCount memberCount:(int32_t)memberCount managementMembers:(NSArray *)managementMembers blacklistMembers:(NSArray *)blacklistMembers generalMembers:(NSArray *)generalMembers privateLink:(NSString *)privateLink migrationData:(TGConversationMigrationData *)migrationData botInfos:(NSDictionary *)botInfos {
    self = [super init];
    if (self != nil) {
        _managementCount = managementCount;
        _blacklistCount = blacklistCount;
        _memberCount = memberCount;
        _managementMembers = managementMembers;
        _blacklistMembers = blacklistMembers;
        _generalMembers = generalMembers;
        _privateLink = privateLink;
        _migrationData = migrationData;
        _botInfos = botInfos;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder {
    return [self initWithManagementCount:[coder decodeInt32ForCKey:"managementCount"] blacklistCount:[coder decodeInt32ForCKey:"blacklistCount"] memberCount:[coder decodeInt32ForCKey:"memberCount"] managementMembers:[coder decodeArrayForCKey:"managementMembers"] blacklistMembers:[coder decodeArrayForCKey:"blacklistMembers"] generalMembers:[coder decodeArrayForCKey:"generalMembers"] privateLink:[coder decodeStringForCKey:"privateLink"] migrationData:[coder decodeObjectForCKey:"migrationData"] botInfos:[coder decodeInt32DictionaryForCKey:"botInfos"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder {
    [coder encodeInt32:_managementCount forCKey:"managementCount"];
    [coder encodeInt32:_blacklistCount forCKey:"blacklistCount"];
    [coder encodeInt32:_memberCount forCKey:"memberCount"];

    [coder encodeArray:_managementMembers forCKey:"managementMembers"];
    [coder encodeArray:_blacklistMembers forCKey:"blacklistMembers"];
    [coder encodeArray:_generalMembers forCKey:"generalMembers"];
    
    [coder encodeString:_privateLink forCKey:"privateLink"];
    [coder encodeObject:_migrationData forCKey:"migrationData"];
    
    [coder encodeInt32Dictionary:_botInfos forCKey:"botInfos"];
}

- (TGCachedConversationData *)updateManagementCount:(int32_t)managementCount blacklistCount:(int32_t)blacklistCount memberCount:(int32_t)memberCount {
    return [[TGCachedConversationData alloc] initWithManagementCount:managementCount blacklistCount:blacklistCount memberCount:memberCount managementMembers:_managementMembers blacklistMembers:_blacklistMembers generalMembers:_generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)blacklistMember:(int32_t)uid timestamp:(int32_t)timestamp {
    int32_t memberCount = _memberCount;
    NSMutableArray *generalMembers = [[NSMutableArray alloc] initWithArray:_generalMembers];
    
    int32_t blacklistCount = _blacklistCount;
    NSMutableArray *blacklistMembers = [[NSMutableArray alloc] initWithArray:_blacklistMembers];
    
    int32_t managementCount = _managementCount;
    NSMutableArray *managementMembers = [[NSMutableArray alloc] initWithArray:_managementMembers];
    
    TGCachedConversationMember *member = [[TGCachedConversationMember alloc] initWithUid:uid role:TGChannelRoleMember timestamp:timestamp];
    if (![blacklistMembers containsObject:member]) {
        blacklistCount++;
        [blacklistMembers addObject:member];
    }
    
    if ([generalMembers containsObject:member]) {
        memberCount = MAX(1, memberCount - 1);
        [generalMembers removeObject:member];
    }
    
    if ([managementMembers containsObject:member]) {
        managementCount = MAX(1, managementCount - 1);
        [managementMembers removeObject:member];
    }
    
    NSMutableDictionary *botInfos = _botInfos == nil ? nil : [[NSMutableDictionary alloc] initWithDictionary:_botInfos];
    [botInfos removeObjectForKey:@(uid)];
    
    return [[TGCachedConversationData alloc] initWithManagementCount:managementCount blacklistCount:blacklistCount memberCount:memberCount managementMembers:managementMembers blacklistMembers:blacklistMembers generalMembers:generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:botInfos];
}

- (TGCachedConversationData *)unblacklistMember:(int32_t)uid timestamp:(int32_t)timestamp {
    int32_t memberCount = _memberCount;
    NSMutableArray *generalMembers = [[NSMutableArray alloc] initWithArray:_generalMembers];
    
    int32_t blacklistCount = _blacklistCount;
    NSMutableArray *blacklistMembers = [[NSMutableArray alloc] initWithArray:_blacklistMembers];
    
    TGCachedConversationMember *member = [[TGCachedConversationMember alloc] initWithUid:uid role:TGChannelRoleMember timestamp:timestamp];
    if ([blacklistMembers containsObject:member]) {
        blacklistCount = MAX(0, blacklistCount - 1);
        [blacklistMembers removeObject:member];
    }
    
    return [[TGCachedConversationData alloc] initWithManagementCount:_managementCount blacklistCount:blacklistCount memberCount:memberCount managementMembers:_managementMembers blacklistMembers:blacklistMembers generalMembers:generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)addManagementMember:(TGCachedConversationMember *)member {
    int32_t managementCount = _managementCount;
    NSMutableArray *managementMembers = [[NSMutableArray alloc] initWithArray:_managementMembers];
    
    if (![managementMembers containsObject:member]) {
        managementCount++;
    } else {
        [managementMembers removeObject:member];
    }
    
    [managementMembers addObject:member];
    
    return [[TGCachedConversationData alloc] initWithManagementCount:managementCount blacklistCount:_blacklistCount memberCount:_memberCount managementMembers:managementMembers blacklistMembers:_blacklistMembers generalMembers:_generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)removeManagementMember:(int32_t)uid {
    int32_t managementCount = _managementCount;
    NSMutableArray *managementMembers = [[NSMutableArray alloc] initWithArray:_managementMembers];
    
    TGCachedConversationMember *member = [[TGCachedConversationMember alloc] initWithUid:uid role:0 timestamp:0];
    if ([managementMembers containsObject:member]) {
        managementCount = MAX(1, managementCount - 1);
        [managementMembers removeObject:member];
    }
    
    return [[TGCachedConversationData alloc] initWithManagementCount:managementCount blacklistCount:_blacklistCount memberCount:_memberCount managementMembers:managementMembers blacklistMembers:_blacklistMembers generalMembers:_generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)addMembers:(NSArray *)uids timestamp:(int32_t)timestamp {
    int32_t memberCount = _memberCount;
    NSMutableArray *generalMembers = [[NSMutableArray alloc] initWithArray:_generalMembers];
    
    int32_t blacklistCount = _blacklistCount;
    NSMutableArray *blacklistMembers = [[NSMutableArray alloc] initWithArray:_blacklistMembers];
    
    for (NSNumber *nUid in uids) {
        TGCachedConversationMember *member = [[TGCachedConversationMember alloc] initWithUid:[nUid intValue] role:TGChannelRoleMember timestamp:timestamp];
        
        if (![generalMembers containsObject:member]) {
            memberCount++;
            [generalMembers insertObject:member atIndex:0];
        }
        
        if ([blacklistMembers containsObject:member]) {
            blacklistCount = MAX(0, blacklistCount - 1);
            [blacklistMembers removeObject:member];
        }
    }
    
    return [[TGCachedConversationData alloc] initWithManagementCount:_managementCount blacklistCount:blacklistCount memberCount:memberCount managementMembers:_managementMembers blacklistMembers:blacklistMembers generalMembers:generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)updatePrivateLink:(NSString *)privateLink {
    return [[TGCachedConversationData alloc] initWithManagementCount:_managementCount blacklistCount:_blacklistCount memberCount:_memberCount managementMembers:_managementMembers blacklistMembers:_blacklistMembers generalMembers:_generalMembers privateLink:privateLink migrationData:_migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)updateGeneralMembers:(NSArray *)generalMembers {
    return [[TGCachedConversationData alloc] initWithManagementCount:_managementCount blacklistCount:_blacklistCount memberCount:_memberCount managementMembers:_managementMembers blacklistMembers:_blacklistMembers generalMembers:generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)updateManagementMembers:(NSArray *)managementMembers {
    return [[TGCachedConversationData alloc] initWithManagementCount:_managementCount blacklistCount:_blacklistCount memberCount:_memberCount managementMembers:managementMembers blacklistMembers:_blacklistMembers generalMembers:_generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)updateBlacklistMembers:(NSArray *)blacklistMembers {
    return [[TGCachedConversationData alloc] initWithManagementCount:_managementCount blacklistCount:_blacklistCount memberCount:_memberCount managementMembers:_managementMembers blacklistMembers:blacklistMembers generalMembers:_generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)updateMigrationData:(TGConversationMigrationData *)migrationData {
    return [[TGCachedConversationData alloc] initWithManagementCount:_managementCount blacklistCount:_blacklistCount memberCount:_memberCount managementMembers:_managementMembers blacklistMembers:_blacklistMembers generalMembers:_generalMembers privateLink:_privateLink migrationData:migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)updateBotInfos:(NSDictionary *)botInfos {
    return [[TGCachedConversationData alloc] initWithManagementCount:_managementCount blacklistCount:_blacklistCount memberCount:_memberCount managementMembers:_managementMembers blacklistMembers:_blacklistMembers generalMembers:_generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:botInfos];
}

@end
