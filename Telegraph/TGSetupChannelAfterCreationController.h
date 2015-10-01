#import "TGCollectionMenuController.h"

#import <SSignalKit/SSignalKit.h>

@class TGConversation;

@interface TGSetupChannelAfterCreationController : TGCollectionMenuController

- (instancetype)initWithConversation:(TGConversation *)conversation exportedLink:(NSString *)exportedLink;

@end
