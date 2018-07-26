#import "TGCollectionMenuController.h"
#import <SSignalKit/SSignalKit.h>
#import "TGPassportForm.h"

@class TGPassportErrors;
@class TGPassportFileUpload;
@class TGPassportMRZ;
@class TGPassportFileCollectionItem;
@class TGButtonCollectionItem;
@class TGPassportDecryptedValue;

@interface TGPassportDocumentController : TGCollectionMenuController
{
    bool _changed;
    
    SVariable *_settings;
    TGPassportType _type;
    
    TGCollectionMenuSection *_scansSection;
    
    TGButtonCollectionItem *_deleteItem;
    TGPassportFile *_hiddenFile;
}

@property (nonatomic, strong) void (^completionBlock)(TGPassportDecryptedValue *details, TGPassportDecryptedValue *document, TGPassportErrors *updatedErrors);
@property (nonatomic, strong) void (^removalBlock)(TGPassportType type);

@property (nonatomic, readonly) TGPassportType type;
@property (nonatomic, readonly) NSArray *files;
@property (nonatomic, readonly) NSArray *allFiles;
@property (nonatomic, readonly) NSArray *uploads;
@property (nonatomic, readonly) TGPassportErrors *errors;

- (instancetype)initWithSettings:(SVariable *)settings files:(NSArray *)files inhibitFiles:(bool)inhibitFiles errors:(TGPassportErrors *)errors existing:(bool)existing;

- (void)enqueueFileUpload:(TGPassportFileUpload *)fileUpload;
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

- (NSString *)deleteTitle;
- (NSString *)deleteConfirmationText;

@end
