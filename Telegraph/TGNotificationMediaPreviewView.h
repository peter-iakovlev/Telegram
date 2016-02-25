#import "TGNotificationPreviewView.h"

@class TGMediaAttachment;

@interface TGNotificationMediaPreviewView : TGNotificationPreviewView

- (instancetype)initWithMessage:(TGMessage *)message conversation:(TGConversation *)conversation attachment:(TGMediaAttachment *)attachment peers:(NSDictionary *)peers;

@end
