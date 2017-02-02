#import "TGConversationScrollMessageStack.h"

@interface TGConversationScrollMessageStack () {
    NSMutableArray *_stack;
}

@end

@implementation TGConversationScrollMessageStack

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _stack = [[NSMutableArray alloc] init];
    }
    return self;
}

- (int32_t)popMessageId {
    NSNumber *last = [_stack lastObject];
    [_stack removeLastObject];
    
    return [last intValue];
}

- (void)pushMessageId:(int32_t)messageId {
    if (messageId != 0) {
        [_stack addObject:@(messageId)];
    }
}

- (void)clearStack {
    [_stack removeAllObjects];
}

- (void)updateStack:(int32_t)visibleMessageId {
    if (_stack.count != 0 && false) {
        NSInteger index = 0;
        NSInteger count = (NSInteger)_stack.count;
        while (index < count) {
            int32_t messageId = [_stack[index] intValue];
            if (messageId <= visibleMessageId) {
                [_stack removeObjectAtIndex:index];
                count--;
            } else {
                index++;
            }
        }
    }
}

@end
