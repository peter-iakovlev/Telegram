#import "TGNotificationPreviewView.h"

@class TGDocumentMediaAttachment;

@interface TGNotificationStickerPreviewView : TGNotificationPreviewView

- (instancetype)initWithMessage:(TGMessage *)message conversation:(TGConversation *)conversation attachment:(TGDocumentMediaAttachment *)attachment peers:(NSDictionary *)peers;

@end
