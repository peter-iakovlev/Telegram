#import "TGCollectionMenuController.h"

@class TGInvoice;
@class TGPaymentRequestedInfo;
@class TGValidatedRequestedInfo;

typedef enum  {
    TGPaymentCheckoutInfoControllerFocusNone = 0,
    TGPaymentCheckoutInfoControllerFocusName = 1,
    TGPaymentCheckoutInfoControllerFocusPhone = 2,
    TGPaymentCheckoutInfoControllerFocusEmail = 3,
    TGPaymentCheckoutInfoControllerFocusAddress = 4
} TGPaymentCheckoutInfoControllerFocus;

@interface TGPaymentCheckoutInfoController : TGCollectionMenuController

@property (nonatomic, copy) void (^completed)(TGPaymentRequestedInfo *requestedInfo, TGValidatedRequestedInfo *validatedInfo, bool saveInfo);

- (instancetype)initWithMessageId:(int32_t)messageId invoice:(TGInvoice *)invoice canSaveInfo:(bool)canSaveInfo enableSaveInfoByDefault:(bool)enableSaveInfoByDefault currentInfo:(TGPaymentRequestedInfo *)currentInfo focus:(TGPaymentCheckoutInfoControllerFocus)focus;

@end
