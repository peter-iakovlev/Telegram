#import "TGCachedUserData.h"

#import "PSKeyValueCoder.h"

@implementation TGCachedUserGroupsInCommon

- (instancetype)initWithGroups:(NSArray<TGConversation *> *)groups {
    self = [super init];
    if (self != nil) {
        _groups = groups;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder {
    return [self initWithGroups:[coder decodeArrayForCKey:"g"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder {
    [coder encodeArray:_groups forCKey:"g"];
}

@end

@implementation TGCachedUserData

- (instancetype)initWithAbout:(NSString *)about groupsInCommonCount:(int32_t)groupsInCommonCount groupsInCommon:(TGCachedUserGroupsInCommon *)groupsInCommon supportsCalls:(bool)supportsCalls {
    self = [super init];
    if (self != nil) {
        _about = about;
        _groupsInCommonCount = groupsInCommonCount;
        _groupsInCommon = groupsInCommon;
        _supportsCalls = supportsCalls;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder {
    return [self initWithAbout:[coder decodeStringForCKey:"about"] groupsInCommonCount:[coder decodeInt32ForCKey:"gcnt"] groupsInCommon:[coder decodeObjectForCKey:"gc"] supportsCalls:[coder decodeInt32ForCKey:"sc"] != 0];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder {
    [coder encodeString:_about forCKey:"about"];
    [coder encodeInt32:_groupsInCommonCount forCKey:"gcnt"];
    [coder encodeObject:_groupsInCommon forCKey:"gc"];
    [coder encodeInt32:_supportsCalls ? 1 : 0 forCKey:"sc"];
}

- (TGCachedUserData *)updateAbout:(NSString *)about {
    return [[TGCachedUserData alloc] initWithAbout:about groupsInCommonCount:_groupsInCommonCount groupsInCommon:_groupsInCommon supportsCalls:_supportsCalls];
}

- (TGCachedUserData *)updateGroupsInCommon:(TGCachedUserGroupsInCommon *)groupsInCommon {
    return [[TGCachedUserData alloc] initWithAbout:_about groupsInCommonCount:_groupsInCommonCount groupsInCommon:groupsInCommon supportsCalls:_supportsCalls];
}

- (TGCachedUserData *)updateGroupsInCommonCount:(int32_t)groupsInCommonCount {
    return [[TGCachedUserData alloc] initWithAbout:_about groupsInCommonCount:groupsInCommonCount groupsInCommon:_groupsInCommon supportsCalls:_supportsCalls];
}

- (TGCachedUserData *)updateSupportsCalls:(bool)supportsCalls {
    return [[TGCachedUserData alloc] initWithAbout:_about groupsInCommonCount:_groupsInCommonCount groupsInCommon:_groupsInCommon supportsCalls:supportsCalls];
}

@end
