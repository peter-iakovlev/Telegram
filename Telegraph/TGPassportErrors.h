#import <Foundation/Foundation.h>

#import "TGPassportForm.h"

@class TLSecureValueError;

@interface TGPassportError : NSObject

@property (nonatomic, readonly) NSString *key;
@property (nonatomic, readonly) NSString *text;

- (instancetype)initWithError:(TLSecureValueError *)error;

@end

@interface TGPassportErrors : NSObject <NSCopying>

- (instancetype)initWithArray:(NSArray *)array fileHashes:(NSSet *)fileHashes;

- (NSArray *)errorsForType:(TGPassportType)type;
- (NSArray *)fieldErrorsForType:(TGPassportType)type;

- (TGPassportError *)errorForTypeMain:(TGPassportType)type;
- (TGPassportError *)errorForType:(TGPassportType)type dataField:(NSString *)field;
- (TGPassportError *)errorForTypeFrontSide:(TGPassportType)type;
- (TGPassportError *)errorForTypeReverseSide:(TGPassportType)type;
- (TGPassportError *)errorForTypeSelfie:(TGPassportType)type;
- (TGPassportError *)errorForTypeFiles:(TGPassportType)type;
- (TGPassportError *)errorForTypeTranslation:(TGPassportType)type;
- (TGPassportError *)errorForType:(TGPassportType)type fileHash:(NSString *)fileHash;
- (TGPassportError *)errorForType:(TGPassportType)type translationFileHash:(NSString *)fileHash;

- (void)correctMainErrorForType:(TGPassportType)type;
- (void)correctErrorForType:(TGPassportType)type dataField:(NSString *)field;
- (void)correctFrontSideErrorForType:(TGPassportType)type;
- (void)correctReverseSideErrorForType:(TGPassportType)type;
- (void)correctSelfieErrorForType:(TGPassportType)type;
- (void)correctTranslationErrorForType:(TGPassportType)type;
- (void)correctFilesErrorForType:(TGPassportType)type;
- (void)correctFileErrorForType:(TGPassportType)type fileHash:(NSString *)fileHash;
- (void)correctTranslationErrorForType:(TGPassportType)type fileHash:(NSString *)fileHash;

@end

