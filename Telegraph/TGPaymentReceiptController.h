#import "TGCollectionMenuController.h"

@class TGMessage;

@interface TGPaymentReceiptController : TGCollectionMenuController

- (instancetype)initWithMessage:(TGMessage *)message receiptMessageId:(int32_t)receiptMessageId;

@end
