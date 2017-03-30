#import <Foundation/Foundation.h>

#import "PSCoding.h"

@class TGConversation;

@interface TGCachedUserGroupsInCommon : NSObject <PSCoding>

@property (nonatomic, strong, readonly) NSArray<TGConversation *> *groups;

- (instancetype)initWithGroups:(NSArray<TGConversation *> *)groups;

@end

@interface TGCachedUserData : NSObject <PSCoding>

@property (nonatomic, strong, readonly) NSString *about;
@property (nonatomic, readonly) int32_t groupsInCommonCount;
@property (nonatomic, strong, readonly) TGCachedUserGroupsInCommon *groupsInCommon;
@property (nonatomic, readonly) bool supportsCalls;
@property (nonatomic, readonly) bool callsPrivate;

- (instancetype)initWithAbout:(NSString *)about groupsInCommonCount:(int32_t)groupsInCommonCount groupsInCommon:(TGCachedUserGroupsInCommon *)groupsInCommon supportsCalls:(bool)supportsCalls callsPrivate:(bool)callsPrivate;

- (TGCachedUserData *)updateAbout:(NSString *)about;
- (TGCachedUserData *)updateGroupsInCommon:(TGCachedUserGroupsInCommon *)groupsInCommon;
- (TGCachedUserData *)updateGroupsInCommonCount:(int32_t)groupsInCommonCount;
- (TGCachedUserData *)updateSupportsCalls:(bool)supportsCalls;
- (TGCachedUserData *)updateCallsPrivate:(bool)callsPrivate;

@end
