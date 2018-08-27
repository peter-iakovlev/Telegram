#import "TGCollectionMenuController.h"
#import <SSignalKit/SSignalKit.h>
#import "TGPassportForm.h"

@class TGPassportErrors;
@class TGPassportFileUpload;
@class TGPassportMRZ;
@class TGPassportFileCollectionItem;
@class TGButtonCollectionItem;
@class TGPassportDecryptedValue;

typedef enum
{
    TGPassportDocumentFileTypeGeneric,
    TGPassportDocumentFileTypeTranslation
} TGPassportDocumentFileType;

@interface TGPassportDocumentController : TGCollectionMenuController
{
    bool _changed;
    
    SVariable *_settings;
    TGPassportType _type;
        
    TGButtonCollectionItem *_deleteItem;
    TGPassportFile *_hiddenFile;
    
    NSMutableDictionary<NSNumber *, TGCollectionMenuSection *> *_fileSections;
}

@property (nonatomic, strong) void (^completionBlock)(TGPassportDecryptedValue *details, TGPassportDecryptedValue *document, TGPassportErrors *updatedErrors);
@property (nonatomic, strong) void (^removalBlock)(TGPassportType type);

@property (nonatomic, readonly) TGPassportType type;
@property (nonatomic, readonly) NSDictionary<NSNumber *, NSArray *> *files;
@property (nonatomic, readonly) NSArray *allFiles;
@property (nonatomic, readonly) NSDictionary<NSNumber *, NSArray *> *uploads;
@property (nonatomic, readonly) TGPassportErrors *errors;

- (instancetype)initWithSettings:(SVariable *)settings files:(NSDictionary *)files fileTypes:(NSArray *)fileTypes errors:(TGPassportErrors *)errors existing:(bool)existing;

- (void)enqueueFileUpload:(TGPassportFileUpload *)fileUpload type:(TGPassportDocumentFileType)type;
- (void)viewFile:(TGPassportFile *)file;
- (void)updateHiddenFile:(TGPassportFile *)hiddenFile;
- (void)deleteFile:(TGPassportFile *)file;
- (CGSize)thumbnailSizeForFile:(id)file;

- (TGPassportFileCollectionItem *)itemForFile:(TGPassportFile *)passportFile;

- (bool)shouldScanDocument;
- (void)applyScannedMRZ:(TGPassportMRZ *)mrz ignoreDocument:(bool)ignoreDocument;

- (void)updateFileErrors;

- (void)updateFiles;
- (void)checkInputValues;

- (bool)hasActiveUploads;

- (void)presentUpdateAppAlert;

- (void)setChanged:(bool)changed;

- (NSString *)deleteTitle;
- (NSString *)deleteConfirmationText;

@end
