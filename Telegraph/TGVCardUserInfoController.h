#import "TGUserInfoController.h"
#import "TGVCard.h"

@class TGContactMediaAttachment;

@interface TGVCardUserInfoController : TGUserInfoController

- (instancetype)initWithUser:(TGUser *)user vcard:(TGVCard *)vcard;
- (instancetype)initWithUser:(TGUser *)user vcard:(TGVCard *)vcard forwardWithCompletion:(void (^)(TGUser *))forwardWithCompletion;

- (void)setupWithVCard:(TGVCard *)vcard skipPhones:(NSArray *)skipPhones;

- (TGVCard *)vcardForCheckedItems;

+ (bool)comparePhone:(NSString *)firstPhone otherPhone:(NSString *)secondPhone;

@end
