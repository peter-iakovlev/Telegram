#import "TGChatMessageListView.h"

@implementation TGChatMessageListView

- (instancetype)initWithMessages:(NSArray *)messages earlierReferenceMessageId:(NSNumber *)earlierReferenceMessageId laterReferenceMessageId:(NSNumber *)laterReferenceMessageId
{
    self = [super init];
    if (self != nil)
    {
        _messages = messages;
        _earlierReferenceMessageId = earlierReferenceMessageId;
        _laterReferenceMessageId = laterReferenceMessageId;
    }
    return self;
}

- (NSArray *)clippedMessages
{
    if (_messages.count > self.rangeCount)
        return [_messages subarrayWithRange:NSMakeRange(0, self.rangeCount)];
    
    return _messages;
}

@end
