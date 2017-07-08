#import "TGCachedConversationData.h"

#import "PSKeyValueCoder.h"

#import "TGChannelBannedRights.h"

#import "TGTelegraph.h"

static bool arrayContainsMemberWithId(NSArray *array, TGCachedConversationMember *member) {
    if (member != nil) {
        for (TGCachedConversationMember *m in array) {
            if (m.uid == member.uid) {
                return true;
            }
        }
    }
    return false;
}

static bool removeArrayMemberWithId(NSMutableArray *array, TGCachedConversationMember *member) {
    if (member != nil) {
        NSUInteger index = 0;
        for (TGCachedConversationMember *m in array) {
            if (m.uid == member.uid) {
                [array removeObjectAtIndex:index];
                return true;
            }
            index += 1;
        }
    }
    return false;
}

static bool updateOrAddArrayMemberWithId(NSMutableArray *array, TGCachedConversationMember *member, TGCachedConversationMember *updated) {
    if (member != nil) {
        NSUInteger index = 0;
        for (TGCachedConversationMember *m in array) {
            if (m.uid == member.uid) {
                array[index] = updated;
                return true;
            }
            index += 1;
        }
    }
    [array addObject:updated];
    return false;
}

@implementation TGCachedConversationMember

- (instancetype)initWithUid:(int32_t)uid isCreator:(bool)isCreator adminRights:(TGChannelAdminRights *)adminRights bannedRights:(TGChannelBannedRights *)bannedRights timestamp:(int32_t)timestamp inviterId:(int32_t)inviterId adminInviterId:(int32_t)adminInviterId kickedById:(int32_t)kickedById adminCanManage:(bool)adminCanManage {
    self = [super init];
    if (self != nil) {
        _uid = uid;
        _isCreator = isCreator;
        _adminRights = adminRights;
        _bannedRights = bannedRights;
        _timestamp = timestamp;
        _inviterId = inviterId;
        _adminInviterId = adminInviterId;
        _kickedById = kickedById;
        _adminCanManage = adminCanManage;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder {
    int32_t uid = [coder decodeInt32ForCKey:"i"];
    int32_t isCreator = [coder decodeInt32ForCKey:"c"];
    TGChannelAdminRights *adminRights = [coder decodeObjectForCKey:"a"];
    TGChannelBannedRights *bannedRights = [coder decodeObjectForCKey:"b"];
    int32_t timestamp = [coder decodeInt32ForCKey:"t"];
    
    return [self initWithUid:uid isCreator:isCreator adminRights:adminRights bannedRights:bannedRights timestamp:timestamp inviterId:[coder decodeInt32ForCKey:"in"] adminInviterId:[coder decodeInt32ForCKey:"aid"] kickedById:[coder decodeInt32ForCKey:"kid"] adminCanManage:[coder decodeInt32ForCKey:"akm"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder {
    [coder encodeInt32:_uid forCKey:"i"];
    [coder encodeInt32:_isCreator forCKey:"c"];
    [coder encodeObject:_adminRights forCKey:"a"];
    [coder encodeObject:_bannedRights forCKey:"b"];
    [coder encodeInt32:_timestamp forCKey:"t"];
    [coder encodeInt32:_inviterId forCKey:"in"];
    [coder encodeInt32:_adminInviterId forCKey:"aid"];
    [coder encodeInt32:_kickedById forCKey:"kid"];
    [coder encodeInt32:_adminCanManage ? 1 : 0 forCKey:"akm"];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TGCachedConversationMember class]] && ((TGCachedConversationMember *)object)->_uid == _uid && ((TGCachedConversationMember *)object)->_isCreator == _isCreator && TGObjectCompare(((TGCachedConversationMember *)object)->_adminRights, _adminRights) && TGObjectCompare(((TGCachedConversationMember *)object)->_bannedRights, _bannedRights) && ((TGCachedConversationMember *)object)->_inviterId == _inviterId && ((TGCachedConversationMember *)object)->_adminInviterId == _adminInviterId && ((TGCachedConversationMember *)object)->_kickedById == _kickedById && ((TGCachedConversationMember *)object)->_adminCanManage == _adminCanManage;
}

- (TGCachedConversationMember *)withUpdatedBannedRights:(TGChannelBannedRights *)bannedRights {
    return [[TGCachedConversationMember alloc] initWithUid:_uid isCreator:_isCreator adminRights:_adminRights bannedRights:bannedRights timestamp:_timestamp inviterId:_inviterId adminInviterId:_adminInviterId kickedById:_kickedById adminCanManage:_adminCanManage];
}

- (TGCachedConversationMember *)withUpdatedAdminRights:(TGChannelAdminRights *)adminRights adminInviterId:(int32_t)adminInviterId adminCanManage:(bool)adminCanManage {
    return [[TGCachedConversationMember alloc] initWithUid:_uid isCreator:_isCreator adminRights:adminRights bannedRights:_bannedRights timestamp:_timestamp inviterId:_inviterId adminInviterId:adminInviterId kickedById:_kickedById adminCanManage:adminCanManage];
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

- (instancetype)initWithManagementCount:(int32_t)managementCount blacklistCount:(int32_t)blacklistCount bannedCount:(int32_t)bannedCount memberCount:(int32_t)memberCount managementMembers:(NSArray *)managementMembers blacklistMembers:(NSArray *)blacklistMembers bannedMembers:(NSArray *)bannedMembers generalMembers:(NSArray *)generalMembers privateLink:(NSString *)privateLink migrationData:(TGConversationMigrationData *)migrationData botInfos:(NSDictionary *)botInfos {
    self = [super init];
    if (self != nil) {
        _managementCount = managementCount;
        _blacklistCount = blacklistCount;
        _bannedCount = bannedCount;
        _memberCount = memberCount;
        _managementMembers = managementMembers;
        _blacklistMembers = blacklistMembers;
        _bannedMembers = bannedMembers;
        _generalMembers = generalMembers;
        _privateLink = privateLink;
        _migrationData = migrationData;
        _botInfos = botInfos;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder {
    return [self initWithManagementCount:[coder decodeInt32ForCKey:"managementCount"] blacklistCount:[coder decodeInt32ForCKey:"blacklistCount"] bannedCount:[coder decodeInt32ForCKey:"bannedCount"] memberCount:[coder decodeInt32ForCKey:"memberCount"] managementMembers:[coder decodeArrayForCKey:"managementMembers"] blacklistMembers:[coder decodeArrayForCKey:"blacklistMembers"] bannedMembers:[coder decodeArrayForCKey:"bannedMembers"] generalMembers:[coder decodeArrayForCKey:"generalMembers"] privateLink:[coder decodeStringForCKey:"privateLink"] migrationData:[coder decodeObjectForCKey:"migrationData"] botInfos:[coder decodeInt32DictionaryForCKey:"botInfos"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder {
    [coder encodeInt32:_managementCount forCKey:"managementCount"];
    [coder encodeInt32:_blacklistCount forCKey:"blacklistCount"];
    [coder encodeInt32:_bannedCount forCKey:"bannedCount"];
    [coder encodeInt32:_memberCount forCKey:"memberCount"];

    [coder encodeArray:_managementMembers forCKey:"managementMembers"];
    [coder encodeArray:_blacklistMembers forCKey:"blacklistMembers"];
    [coder encodeArray:_bannedMembers forCKey:"bannedMembers"];
    [coder encodeArray:_generalMembers forCKey:"generalMembers"];
    
    [coder encodeString:_privateLink forCKey:"privateLink"];
    [coder encodeObject:_migrationData forCKey:"migrationData"];
    
    [coder encodeInt32Dictionary:_botInfos forCKey:"botInfos"];
}

- (TGCachedConversationData *)updateManagementCount:(int32_t)managementCount blacklistCount:(int32_t)blacklistCount bannedCount:(int32_t)bannedCount memberCount:(int32_t)memberCount {
    return [[TGCachedConversationData alloc] initWithManagementCount:managementCount blacklistCount:blacklistCount bannedCount:bannedCount memberCount:memberCount managementMembers:_managementMembers blacklistMembers:_blacklistMembers bannedMembers:_bannedMembers generalMembers:_generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)updateMemberBannedRights:(int32_t)uid rights:(TGChannelBannedRights *)rights timestamp:(int32_t)timestamp isMember:(bool)isMember kickedById:(int32_t)kickedById {
    int32_t memberCount = _memberCount;
    NSMutableArray *generalMembers = [[NSMutableArray alloc] initWithArray:_generalMembers];
    
    int32_t blacklistCount = _blacklistCount;
    NSMutableArray *blacklistMembers = [[NSMutableArray alloc] initWithArray:_blacklistMembers];
    
    int32_t managementCount = _managementCount;
    NSMutableArray *managementMembers = [[NSMutableArray alloc] initWithArray:_managementMembers];
    
    int32_t bannedCount = _bannedCount;
    NSMutableArray *bannedMembers = [[NSMutableArray alloc] initWithArray:_bannedMembers];
    
    TGCachedConversationMember *member = [[TGCachedConversationMember alloc] initWithUid:uid isCreator:false adminRights:nil bannedRights:rights.numberOfRestrictions == 0 ? nil : rights timestamp:timestamp inviterId:0 adminInviterId:0 kickedById:kickedById adminCanManage:false];
    
    if (isMember) {
        if (!updateOrAddArrayMemberWithId(generalMembers, member, member)) {
            memberCount += 1;
        }
    } else {
        if (removeArrayMemberWithId(generalMembers, member)) {
            memberCount -= 1;
        }
    }
    
    if (rights.numberOfRestrictions == 0) {
        if (removeArrayMemberWithId(blacklistMembers, member)) {
            blacklistCount -= 1;
        }
        if (removeArrayMemberWithId(bannedMembers, member)) {
            bannedCount -= 1;
        }
    } else if (!rights.banReadMessages) {
        if (!updateOrAddArrayMemberWithId(generalMembers, member, member)) {
            memberCount += 1;
        }
        if (removeArrayMemberWithId(blacklistMembers, member)) {
            blacklistCount -= 1;
        }
        if (!updateOrAddArrayMemberWithId(bannedMembers, member, member)) {
            bannedCount += 1;
        }
    } else {
        if (!updateOrAddArrayMemberWithId(blacklistMembers, member, member)) {
            blacklistCount += 1;
        }
        if (removeArrayMemberWithId(bannedMembers, member)) {
            bannedCount -= 1;
        }
    }
    
    NSMutableDictionary *botInfos = _botInfos == nil ? nil : [[NSMutableDictionary alloc] initWithDictionary:_botInfos];
    if (rights.banReadMessages) {
        [botInfos removeObjectForKey:@(uid)];
    }
    
    return [[TGCachedConversationData alloc] initWithManagementCount:managementCount blacklistCount:blacklistCount bannedCount:bannedCount memberCount:memberCount managementMembers:managementMembers blacklistMembers:blacklistMembers bannedMembers:bannedMembers generalMembers:generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:botInfos];
}

- (TGCachedConversationData *)addManagementMember:(TGCachedConversationMember *)member {
    int32_t managementCount = _managementCount;
    NSMutableArray *managementMembers = [[NSMutableArray alloc] initWithArray:_managementMembers];
    NSMutableArray *generalMembers = [[NSMutableArray alloc] initWithArray:_generalMembers];
    
    if (!removeArrayMemberWithId(managementMembers, member)) {
        managementCount++;
    }
    
    [managementMembers addObject:member];
    
    NSUInteger index = [generalMembers indexOfObject:member];
    if (index != NSNotFound) {
        TGCachedConversationMember *generalMember = generalMembers[index];
        generalMembers[index] = [[TGCachedConversationMember alloc] initWithUid:generalMember.uid isCreator:false adminRights:member.adminRights bannedRights:nil timestamp:generalMember.timestamp inviterId:member.inviterId adminInviterId:member.adminInviterId kickedById:0 adminCanManage:false];
    }
    
    return [[TGCachedConversationData alloc] initWithManagementCount:managementCount blacklistCount:_blacklistCount bannedCount:_bannedCount memberCount:_memberCount managementMembers:managementMembers blacklistMembers:_blacklistMembers bannedMembers:_bannedMembers generalMembers:generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)removeManagementMember:(int32_t)uid {
    int32_t managementCount = _managementCount;
    NSMutableArray *managementMembers = [[NSMutableArray alloc] initWithArray:_managementMembers];
    NSMutableArray *generalMembers = [[NSMutableArray alloc] initWithArray:_generalMembers];
    
    TGCachedConversationMember *member = [[TGCachedConversationMember alloc] initWithUid:uid isCreator:false adminRights:nil bannedRights:nil timestamp:0 inviterId:0 adminInviterId:0 kickedById:0 adminCanManage:false];
    if (removeArrayMemberWithId(managementMembers, member)) {
        managementCount = MAX(1, managementCount - 1);
    }
    
    NSUInteger index = [generalMembers indexOfObject:member];
    if (index != NSNotFound) {
        TGCachedConversationMember *generalMember = generalMembers[index];
        generalMembers[index] = [[TGCachedConversationMember alloc] initWithUid:generalMember.uid isCreator:false adminRights:nil bannedRights:nil timestamp:generalMember.timestamp inviterId:generalMember.inviterId adminInviterId:0 kickedById:0 adminCanManage:false];
    }
    
    return [[TGCachedConversationData alloc] initWithManagementCount:managementCount blacklistCount:_blacklistCount bannedCount:_bannedCount memberCount:_memberCount managementMembers:managementMembers blacklistMembers:_blacklistMembers bannedMembers:_bannedMembers generalMembers:generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)addMembers:(NSArray *)uids timestamp:(int32_t)timestamp {
    int32_t memberCount = _memberCount;
    NSMutableArray *generalMembers = [[NSMutableArray alloc] initWithArray:_generalMembers];
    
    int32_t blacklistCount = _blacklistCount;
    NSMutableArray *blacklistMembers = [[NSMutableArray alloc] initWithArray:_blacklistMembers];
    
    NSMutableArray *bannedMembers = [[NSMutableArray alloc] initWithArray:_bannedMembers];
    
    for (NSNumber *nUid in uids) {
        TGCachedConversationMember *member = [[TGCachedConversationMember alloc] initWithUid:[nUid intValue] isCreator:false adminRights:nil bannedRights:nil timestamp:timestamp inviterId:0 adminInviterId:0 kickedById:0 adminCanManage:false];
        
        if (!arrayContainsMemberWithId(generalMembers, member)) {
            memberCount++;
            [generalMembers insertObject:member atIndex:0];
        }
        
        if (removeArrayMemberWithId(blacklistMembers, member)) {
            blacklistCount = MAX(0, blacklistCount - 1);
        }
    }
    
    return [[TGCachedConversationData alloc] initWithManagementCount:_managementCount blacklistCount:blacklistCount bannedCount:_bannedCount memberCount:memberCount managementMembers:_managementMembers blacklistMembers:blacklistMembers bannedMembers:bannedMembers generalMembers:generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)updatePrivateLink:(NSString *)privateLink {
    return [[TGCachedConversationData alloc] initWithManagementCount:_managementCount blacklistCount:_blacklistCount bannedCount:_bannedCount memberCount:_memberCount managementMembers:_managementMembers blacklistMembers:_blacklistMembers bannedMembers:_bannedMembers generalMembers:_generalMembers privateLink:privateLink migrationData:_migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)updateGeneralMembers:(NSArray *)generalMembers {
    return [[TGCachedConversationData alloc] initWithManagementCount:_managementCount blacklistCount:_blacklistCount bannedCount:_bannedCount memberCount:_memberCount managementMembers:_managementMembers blacklistMembers:_blacklistMembers bannedMembers:_bannedMembers generalMembers:generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)updateManagementMembers:(NSArray *)managementMembers {
    return [[TGCachedConversationData alloc] initWithManagementCount:_managementCount blacklistCount:_blacklistCount bannedCount:_bannedCount memberCount:_memberCount managementMembers:managementMembers blacklistMembers:_blacklistMembers bannedMembers:_bannedMembers generalMembers:_generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)updateBlacklistMembers:(NSArray *)blacklistMembers {
    return [[TGCachedConversationData alloc] initWithManagementCount:_managementCount blacklistCount:_blacklistCount bannedCount:_bannedCount memberCount:_memberCount managementMembers:_managementMembers blacklistMembers:blacklistMembers bannedMembers:_bannedMembers generalMembers:_generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)updateBannedMembers:(NSArray *)bannedMembers {
    return [[TGCachedConversationData alloc] initWithManagementCount:_managementCount blacklistCount:_blacklistCount bannedCount:_bannedCount memberCount:_memberCount managementMembers:_managementMembers blacklistMembers:_blacklistMembers bannedMembers:bannedMembers generalMembers:_generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)updateMigrationData:(TGConversationMigrationData *)migrationData {
    return [[TGCachedConversationData alloc] initWithManagementCount:_managementCount blacklistCount:_blacklistCount bannedCount:_bannedCount memberCount:_memberCount managementMembers:_managementMembers blacklistMembers:_blacklistMembers bannedMembers:_bannedMembers generalMembers:_generalMembers privateLink:_privateLink migrationData:migrationData botInfos:_botInfos];
}

- (TGCachedConversationData *)updateBotInfos:(NSDictionary *)botInfos {
    return [[TGCachedConversationData alloc] initWithManagementCount:_managementCount blacklistCount:_blacklistCount bannedCount:_bannedCount memberCount:_memberCount managementMembers:_managementMembers blacklistMembers:_blacklistMembers bannedMembers:_bannedMembers generalMembers:_generalMembers privateLink:_privateLink migrationData:_migrationData botInfos:botInfos];
}

@end
