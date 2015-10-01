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

@end
