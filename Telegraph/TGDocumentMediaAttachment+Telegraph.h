#import <LegacyComponents/LegacyComponents.h>

#import "TL/TLMetaScheme.h"

#import "SecretLayer23.h"
#import "SecretLayer46.h"
#import "SecretLayer66.h"
#import "SecretLayer73.h"

@interface TGDocumentMediaAttachment (Telegraph)

+ (NSArray *)parseAttribtues:(NSArray *)descs;

- (instancetype)initWithTelegraphDocumentDesc:(TLDocument *)desc;
- (instancetype)initWithSecret23Desc:(Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)desc;
- (instancetype)initWithSecret46ExternalDesc:(Secret46_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)desc;
- (instancetype)initWithSecret66ExternalDesc:(Secret66_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)desc;
- (instancetype)initWithSecret73ExternalDesc:(Secret73_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)desc;

@end
