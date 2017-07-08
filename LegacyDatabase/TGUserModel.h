#import <Foundation/Foundation.h>

#import <LegacyDatabase/TGFileLocation.h>

@class TGPrivateChatModel;

@interface TGUserModel : NSObject

@property (nonatomic, readonly) int32_t userId;
@property (nonatomic, readonly) int64_t accessHash;

@property (nonatomic, strong, readonly) NSString *firstName;
@property (nonatomic, strong, readonly) NSString *lastName;

@property (nonatomic, strong, readonly) TGFileLocation *avatarLocation;

- (instancetype)initWithUserId:(int32_t)userId accessHash:(int64_t)accessHash firstName:(NSString *)firstName lastName:(NSString *)lastName avatarLocation:(TGFileLocation *)avatarLocation;

- (NSString *)displayName;

- (TGPrivateChatModel *)chatModel;

@end
