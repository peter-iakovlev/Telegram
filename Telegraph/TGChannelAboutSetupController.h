#import "TGCollectionMenuController.h"

@class TGConversation;

@interface TGChannelAboutSetupController : TGCollectionMenuController

- (instancetype)initWithConversation:(TGConversation *)conversation;
- (instancetype)initWithBlock:(void (^)(NSString *about))block text:(NSString *)text;

@end
