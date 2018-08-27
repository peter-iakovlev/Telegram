#import "TGPassportDocumentController.h"
#import "TGPassportForm.h"

@class TGPassportDecryptedValue;
@class TGPassportErorrs;
@class SVariable;

@interface TGPassportAddressController : TGPassportDocumentController

- (instancetype)initWithType:(TGPassportType)type address:(TGPassportDecryptedValue *)address document:(TGPassportDecryptedValue *)document documentOnly:(bool)documentOnly translation:(bool)translation editing:(bool)editing settings:(SVariable *)settings errors:(TGPassportErrors *)errors;
- (instancetype)initWithType:(TGPassportType)type address:(TGPassportDecryptedValue *)address documentOnly:(bool)documentOnly translation:(bool)translation editing:(bool)editing uploads:(NSArray *)uploads settings:(SVariable *)settings errors:(TGPassportErrors *)errors;

- (void)setScrollToTranslation;

+ (NSString *)documentDisplayNameForType:(TGPassportType)type;

@end
