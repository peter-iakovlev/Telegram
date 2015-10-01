#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "TGBotInfo.h"
#import "TGBotReplyMarkup.h"
#import "TL/TLMetaScheme.h"

@interface TGBotSignals : NSObject

+ (TGBotInfo *)botInfoForInfo:(TLBotInfo *)info;
+ (TGBotReplyMarkup *)botReplyMarkupForMarkup:(TLReplyMarkup *)markup userId:(int32_t)userId messageId:(int32_t)messageId hidePreviousMarkup:(bool *)hidePreviousMarkup forceReply:(bool *)forceReply onlyIfRelevantToUser:(bool *)onlyIfRelevantToUser;

+ (SSignal *)botInfoForUserId:(int32_t)userId;
+ (SSignal *)botStartForUserId:(int32_t)userId payload:(NSString *)payload;
+ (SSignal *)botInviteUserId:(int32_t)userId toGroupId:(int32_t)groupId payload:(NSString *)payload;

@end
