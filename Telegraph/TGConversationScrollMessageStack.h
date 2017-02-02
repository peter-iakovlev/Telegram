#import <Foundation/Foundation.h>

@interface TGConversationScrollMessageStack : NSObject

- (int32_t)popMessageId;
- (void)pushMessageId:(int32_t)messageId;
- (void)clearStack;
- (void)updateStack:(int32_t)visibleMessageId;

@end
