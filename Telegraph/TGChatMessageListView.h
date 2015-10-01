#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

@interface TGChatMessageListView : NSObject

@property (nonatomic, strong, readonly) NSArray *messages;
@property (nonatomic, strong, readonly) NSNumber *earlierReferenceMessageId;
@property (nonatomic, strong, readonly) NSNumber *laterReferenceMessageId;

- (instancetype)initWithMessages:(NSArray *)messages earlierReferenceMessageId:(NSNumber *)earlierReferenceMessageId laterReferenceMessageId:(NSNumber *)laterReferenceMessageId;

@end
