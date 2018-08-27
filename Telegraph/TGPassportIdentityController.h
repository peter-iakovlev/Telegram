#import "TGPassportDocumentController.h"
#import "TGPassportForm.h"

@class TGPassportDecryptedValue;
@class TGPassportErrors;
@class SVariable;

@interface TGPassportIdentityController : TGPassportDocumentController

@property (nonatomic, strong) NSArray *acceptedTypes;

- (instancetype)initWithType:(TGPassportType)type details:(TGPassportDecryptedValue *)details document:(TGPassportDecryptedValue *)document documentOnly:(bool)documentOnly selfie:(bool)selfie translation:(bool)translation nativeNames:(bool)nativeNames editing:(bool)editing settings:(SVariable *)settings errors:(TGPassportErrors *)errors;
- (instancetype)initWithType:(TGPassportType)type details:(TGPassportDecryptedValue *)details documentOnly:(bool)documentOnly selfie:(bool)selfie translation:(bool)translation nativeNames:(bool)nativeNames editing:(bool)editing upload:(TGPassportFileUpload *)upload settings:(SVariable *)settings errors:(TGPassportErrors *)errors;

+ (NSString *)documentDisplayNameForType:(TGPassportType)type;

- (void)setLanguagesSignal:(SSignal *)languagesSignal;
- (void)setScrollToSelfie;
- (void)setScrollToTranslation;
- (void)setScrollToNativeNames;

+ (NSDateFormatter *)dateFormatter;

@end
