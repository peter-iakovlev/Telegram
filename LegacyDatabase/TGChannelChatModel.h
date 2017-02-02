#import "TGChatModel.h"

#import <LegacyDatabase/TGFileLocation.h>

@interface TGChannelChatModel : TGChatModel

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) TGFileLocation *avatarLocation;
@property (nonatomic, readonly) bool isGroup;
@property (nonatomic, readonly) int64_t accessHash;

- (instancetype)initWithChannelId:(int32_t)channelId title:(NSString *)title avatarLocation:(TGFileLocation *)avatarLocation isGroup:(bool)isGroup accessHash:(int64_t)accessHash;

@end
