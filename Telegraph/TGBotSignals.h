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
+ (SSignal *)botInviteUserId:(int32_t)userId toPeerId:(int64_t)peerId accessHash:(int64_t)accessHash payload:(NSString *)payload;

+ (SSignal *)botContextResultForUserId:(int32_t)userId query:(NSString *)query offset:(NSString *)offset;

@end
