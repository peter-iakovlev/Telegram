#import <Foundation/Foundation.h>

@class TGLegacyUser;
@class TGChatModel;
@class SSignal;

@interface TGLegacyDatabase : NSObject

- (instancetype)initWithPath:(NSString *)path;
//- (SSignal *)contactUsersMatchingQuery:(NSString *)query;
- (SSignal *)contactUsersMatchingPhone:(NSString *)phoneNumber;
- (NSArray<TGLegacyUser *> *)contactUsersMatchingPhoneSync:(NSString *)phoneNumber;
- (NSArray<TGLegacyUser *> *)topUsers;
- (NSDictionary<NSNumber *, NSNumber *> *)unreadCountsForUsers:(NSArray<TGLegacyUser *> *)users;

- (TGChatModel *)conversationWithIdSync:(int64_t)conversationId;

- (NSData *)customPropertySync:(NSString *)name;

@end
