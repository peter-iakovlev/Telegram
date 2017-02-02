#import <SSignalKit/SSignalKit.h>

@class TGWidgetUser;

@interface TGWidgetSignals : NSObject

+ (SSignal *)peopleSignal;

+ (SSignal *)userAvatarWithUser:(TGWidgetUser *)user clientUserId:(int32_t)clientUserId;

@end
