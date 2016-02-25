#import "TGNotificationPreviewView.h"

@class TGContactMediaAttachment;

@interface TGNotificationContactPreviewView : TGNotificationPreviewView

- (instancetype)initWithMessage:(TGMessage *)message conversation:(TGConversation *)conversation attachment:(TGContactMediaAttachment *)attachment peers:(NSDictionary *)peers;

@end
