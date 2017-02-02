#import <LegacyDatabase/TGChatModel.h>

#import <LegacyDatabase/TGFileLocation.h>

@interface TGGroupChatModel : TGChatModel

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) TGFileLocation *avatarLocation;

- (instancetype)initWithGroupId:(int32_t)groupId title:(NSString *)title avatarLocation:(TGFileLocation *)avatarLocation;

@end
