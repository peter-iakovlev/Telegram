#import <Foundation/Foundation.h>

@interface TGNotificationException : NSObject

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly, strong) NSNumber *notificationType;
@property (nonatomic, readonly, strong) NSNumber *muteUntil;

- (instancetype)initWithPeerId:(int64_t)peerId notificationType:(NSNumber *)notificationType muteUntil:(NSNumber *)muteUntil;

@end
