#import "TGNotificationPreviewView.h"

@class TGAudioMediaAttachment;

@interface TGNotificationAudioPreviewView : TGNotificationPreviewView

- (instancetype)initWithMessage:(TGMessage *)message conversation:(TGConversation *)conversation attachment:(id)attachment peers:(NSDictionary *)peers;

@end
