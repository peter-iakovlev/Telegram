#import "TGPassportDocumentController.h"
#import "TGPassportForm.h"

@class TGPassportDecryptedValue;
@class TGPassportErorrs;
@class SVariable;

@interface TGPassportAddressController : TGPassportDocumentController

- (instancetype)initWithType:(TGPassportType)type address:(TGPassportDecryptedValue *)address document:(TGPassportDecryptedValue *)document documentOnly:(bool)documentOnly settings:(SVariable *)settings errors:(TGPassportErrors *)errors;
- (instancetype)initWithType:(TGPassportType)type address:(TGPassportDecryptedValue *)address documentOnly:(bool)documentOnly uploads:(NSArray *)uploads settings:(SVariable *)settings errors:(TGPassportErrors *)errors;

+ (NSString *)documentDisplayNameForType:(TGPassportType)type;

@end
