#import "TGNotificationPreviewView.h"

@class TGDocumentMediaAttachment;

@interface TGNotificationFilePreviewView : TGNotificationPreviewView

- (instancetype)initWithMessage:(TGMessage *)message conversation:(TGConversation *)conversation attachment:(TGDocumentMediaAttachment *)attachment peers:(NSDictionary *)peers;

@end
