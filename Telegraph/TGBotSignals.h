#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "TGBotInfo.h"
#import "TGBotReplyMarkup.h"
#import "TL/TLMetaScheme.h"

#import "TGPaymentForm.h"

@interface TGBotSignals : NSObject

+ (TGBotInfo *)botInfoForInfo:(TLBotInfo *)info;
+ (TGBotReplyMarkup *)botReplyMarkupForMarkup:(TLReplyMarkup *)markup userId:(int32_t)userId messageId:(int32_t)messageId hidePreviousMarkup:(bool *)hidePreviousMarkup forceReply:(bool *)forceReply onlyIfRelevantToUser:(bool *)onlyIfRelevantToUser;

+ (SSignal *)botInfoForUserId:(int32_t)userId;
+ (SSignal *)botStartForUserId:(int32_t)userId payload:(NSString *)payload;
+ (SSignal *)botInviteUserId:(int32_t)userId toPeerId:(int64_t)peerId accessHash:(int64_t)accessHash payload:(NSString *)payload;

+ (SSignal *)botContextResultForUserId:(int32_t)userId peerId:(int64_t)peerId accessHash:(int64_t)accessHash query:(NSString *)query geoPoint:(SSignal *)geoPoint offset:(NSString *)offset;
+ (SSignal *)botCallback:(int64_t)conversationId accessHash:(int64_t)accessHash messageId:(int32_t)messageId data:(NSData *)data isGame:(bool)isGame;

+ (SSignal *)shareBotGame:(int64_t)fromPeerId messageId:(int32_t)messageId toPeerId:(int64_t)peerId withScore:(bool)withScore;
+ (SSignal *)sendBotGame:(NSString *)shortName toPeerId:(int64_t)peerId botId:(int32_t)botId;

+ (SSignal *)paymentForm:(int32_t)messageId;
+ (SSignal *)paymentReceipt:(int32_t)messageId;
+ (SSignal *)validateRequestedPaymentInfo:(int32_t)messageId info:(TGPaymentRequestedInfo *)info saveInfo:(bool)saveInfo;
+ (SSignal *)sendPayment:(int32_t)messageId infoId:(NSString *)infoId shippingOptionId:(NSString *)shippingOptionId credentials:(id)credentials;

@end
