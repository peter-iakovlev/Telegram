#import "TGNotificationPreviewView.h"

@class TGLocationMediaAttachment;

@interface TGNotificationVenuePreviewView : TGNotificationPreviewView

- (instancetype)initWithMessage:(TGMessage *)message conversation:(TGConversation *)conversation attachment:(TGLocationMediaAttachment *)attachment peers:(NSDictionary *)peers;

@end
