#import "TGUserInfoController.h"

@interface TGBotUserInfoController : TGUserInfoController

- (instancetype)initWithUid:(int32_t)uid sendCommand:(void (^)(NSString *))sendCommand;

@end
