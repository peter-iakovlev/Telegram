#import <Foundation/Foundation.h>

@interface TGGroupInvitationInfo : NSObject

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, readonly) bool alreadyAccepted;
@property (nonatomic, readonly) bool left;
@property (nonatomic, readonly) bool isChannel;
@property (nonatomic, readonly) bool isChannelGroup;
@property (nonatomic, readonly) int64_t peerId;

- (instancetype)initWithTitle:(NSString *)title alreadyAccepted:(bool)alreadyAccepted left:(bool)left isChannel:(bool)isChannel isChannelGroup:(bool)isChannelGroup peerId:(int64_t)peerId;

@end
