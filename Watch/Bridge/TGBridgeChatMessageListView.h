#import "TGBridgeCommon.h"

@class SSignal;

@interface TGBridgeChatMessageListView : NSObject <NSCoding>
{
    NSArray *_messages;
    NSNumber *_earlierReferenceMessageId;
    NSNumber *_laterReferenceMessageId;
}

@property (nonatomic, readonly) NSArray *messages;
@property (nonatomic, readonly) SSignal *earlierView;
@property (nonatomic, readonly) SSignal *laterView;

//- (instancetype)initWithDictionary:(NSDictionary *)dictionary adjacentViewsSignalProducer:(SSignal *(^)(int32_t))adjacentViewsSignalProducer;

@end

extern NSString *const TGBridgeChatMessageListViewKey;
