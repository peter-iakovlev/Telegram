#import "TGPassportDocumentController.h"
#import "TGPassportForm.h"

@class TGPassportDecryptedValue;
@class TGPassportErrors;
@class SVariable;

@interface TGPassportIdentityController : TGPassportDocumentController

- (instancetype)initWithType:(TGPassportType)type details:(TGPassportDecryptedValue *)details document:(TGPassportDecryptedValue *)document documentOnly:(bool)documentOnly selfie:(bool)selfie settings:(SVariable *)settings errors:(TGPassportErrors *)errors;
- (instancetype)initWithType:(TGPassportType)type details:(TGPassportDecryptedValue *)details documentOnly:(bool)documentOnly selfie:(bool)selfie upload:(TGPassportFileUpload *)upload settings:(SVariable *)settings errors:(TGPassportErrors *)errors;

+ (NSString *)documentDisplayNameForType:(TGPassportType)type;

- (void)setScrollToSelfie;

@end
