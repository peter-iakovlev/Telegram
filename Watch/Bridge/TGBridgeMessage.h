#import "TGBridgeCommon.h"
#import "TGBridgeImageMediaAttachment.h"
#import "TGBridgeVideoMediaAttachment.h"
#import "TGBridgeAudioMediaAttachment.h"
#import "TGBridgeDocumentMediaAttachment.h"
#import "TGBridgeLocationMediaAttachment.h"
#import "TGBridgeContactMediaAttachment.h"
#import "TGBridgeActionMediaAttachment.h"
#import "TGBridgeReplyMessageMediaAttachment.h"
#import "TGBridgeForwardedMessageMediaAttachment.h"
#import "TGBridgeWebPageMediaAttachment.h"
#import "TGBridgeUnsupportedMediaAttachment.h"

typedef enum {
    TGBridgeMessageDeliveryStateDelivered = 0,
    TGBridgeMessageDeliveryStatePending = 1,
    TGBridgeMessageDeliveryStateFailed = 2
} TGBridgeMessageDeliveryState;

@interface TGBridgeMessage : NSObject <NSCoding>
{
    int32_t _identifier;
    NSTimeInterval _date;
    int64_t _randomId;
    bool _unread;
    bool _outgoing;
    bool _deliveryError;
    TGBridgeMessageDeliveryState _deliveryState;
    int64_t _fromUid;
    int64_t _toUid;
    int64_t _cid;
    NSString *_text;
    NSArray *_media;
    bool _forceReply;
}

@property (nonatomic, readonly) int32_t identifier;
@property (nonatomic, readonly) NSTimeInterval date;
@property (nonatomic, readonly) int64_t randomId;
@property (nonatomic, readonly) bool unread;
@property (nonatomic, readonly) bool deliveryError;
@property (nonatomic, readonly) TGBridgeMessageDeliveryState deliveryState;
@property (nonatomic, readonly) bool outgoing;
@property (nonatomic, readonly) int64_t fromUid;
@property (nonatomic, readonly) int64_t toUid;
@property (nonatomic, readonly) int64_t cid;
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSArray *media;
@property (nonatomic, readonly) bool forceReply;

- (NSIndexSet *)involvedUserIds;

+ (instancetype)temporaryNewMessageForText:(NSString *)text userId:(int32_t)userId;
+ (instancetype)temporaryNewMessageForText:(NSString *)text userId:(int32_t)userId replyToMessage:(TGBridgeMessage *)replyToMessage;
+ (instancetype)temporaryNewMessageForSticker:(TGBridgeDocumentMediaAttachment *)sticker userId:(int32_t)userId;
+ (instancetype)temporaryNewMessageForLocation:(TGBridgeLocationMediaAttachment *)location userId:(int32_t)userId;
+ (instancetype)temporaryNewMessageForAudioWithDuration:(int32_t)duration userId:(int32_t)userId;

@end

extern NSString *const TGBridgeMessageKey;
extern NSString *const TGBridgeMessagesArrayKey;
