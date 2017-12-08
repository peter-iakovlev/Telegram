#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

@class TGPreparedMessage;
@class TLInputMedia;
@class TGModernSendMessageActor;

@interface TGMediaPostingContext : NSObject

- (void)enqueueMessage:(TGPreparedMessage *)message;
- (SSignal *)readyToPostPreparedMessage:(TGPreparedMessage *)message;
- (void)notifyPostedMessage:(TGPreparedMessage *)message;

- (void)startMediaUploadForPreparedMessage:(TGPreparedMessage *)preparedMessage actor:(TGModernSendMessageActor *)actor;
- (void)maybeNotifyGroupedUploadProgressWithPreparedMessage:(TGPreparedMessage *)preparedMessage;
- (void)failPreparedMessage:(TGPreparedMessage *)preparedMessage;
- (void)cancelPreparedMessage:(TGPreparedMessage *)preparedMessage;

- (void)saveMessageMedia:(TLInputMedia *)media forPreparedMessage:(TGPreparedMessage *)preparedMessage;
- (void)markPreparedMessageAsReadyToSend:(TGPreparedMessage *)preparedMessage;
- (void)notifyPostedGroupedId:(int64_t)groupedId;

- (SSignal *)readyToPostGroupedId:(int64_t)groupedId force:(bool)force;
- (int32_t)replyToIdForGroupedId:(int64_t)groupedId;
- (NSArray *)multiMediaForGroupedId:(int64_t)groupedId;
- (NSArray *)actorsForGroupedId:(int64_t)groupedId;

@end
