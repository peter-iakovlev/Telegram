#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

@interface TGChatMessageListView : NSObject

@property (nonatomic, strong, readonly) NSArray *messages;
@property (nonatomic, strong, readonly) NSNumber *earlierReferenceMessageId;
@property (nonatomic, strong, readonly) NSNumber *laterReferenceMessageId;

@property (nonatomic, assign) NSUInteger rangeCount;
@property (nonatomic, assign) bool maybeHasMessagesOnTop;
@property (nonatomic, readonly) NSArray *clippedMessages;

@property (nonatomic, assign) bool isChannel;
@property (nonatomic, assign) bool isChannelGroup;

- (instancetype)initWithMessages:(NSArray *)messages earlierReferenceMessageId:(NSNumber *)earlierReferenceMessageId laterReferenceMessageId:(NSNumber *)laterReferenceMessageId;

@end
