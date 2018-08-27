#import "TGPassportDocumentController.h"

#import "TGLegacyComponentsContext.h"

#import "TGAppDelegate.h"
#import "TGTelegraph.h"
#import "TGPresentation.h"
#import "TLMetaScheme.h"

#import <LegacyComponents/TGDateUtils.h>
#import <LegacyComponents/TGPassportOCR.h>

#import "PhotoResources.h"

#import "TGHeaderCollectionItem.h"
#import "TGUsernameCollectionItem.h"
#import "TGVariantCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGPassportFileCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGTwoStepConfig.h"
#import "TGPassportForm.h"
#import "TGPassportFile.h"
#import "TGPassportSignals.h"
#import "TGPassportErrors.h"
#import "TGPassportICloud.h"

#import "TGPassportIdentityController.h"

#import "TGPassportGalleryModel.h"

#import "TGCustomAlertView.h"
#import <LegacyComponents/TGPassportAttachMenu.h>

#import "TGPassportRequestController.h"

@interface TGPassportDocumentController ()
{
    NSArray *_fileTypes;
    
    bool _uploading;
    SDisposableSet *_uploadDisposables;
    SMetaDisposable *_deleteDisposable;
    
    NSMutableDictionary *_fileErrorItems;
}

@property (nonatomic, strong) NSMutableDictionary *uploads;

@end

@implementation TGPassportDocumentController

- (instancetype)initWithSettings:(SVariable *)settings files:(NSDictionary *)files fileTypes:(NSArray *)fileTypes errors:(TGPassportErrors *)errors existing:(bool)existing
{
    self = [super init];
    if (self != nil)
    {
        _fileTypes = fileTypes;
        _settings = settings;
        _files = files;
        if (_files == nil)
        {
            NSMutableDictionary *files = [[NSMutableDictionary alloc] init];
            for (NSNumber *type in fileTypes)
            {
                files[type] = @[];
            }
            _files = files;
        }
        _uploads = [[NSMutableDictionary alloc] init];
        for (NSNumber *type in fileTypes)
        {
            _uploads[type] = [[NSMutableArray alloc] init];
        }
        _errors = [errors copy];
        
        _fileSections = [[NSMutableDictionary alloc] init];
        _fileErrorItems = [[NSMutableDictionary alloc] init];
        
        for (NSNumber *type in fileTypes)
        {
            NSString *title = nil;
            NSString *comment = nil;
            switch (type.integerValue)
            {
                case TGPassportDocumentFileTypeGeneric:
                    title = TGLocalized(@"Passport.Scans");
                    comment = TGLocalized(@"Passport.Identity.ScansHelp");
                    break;
                case TGPassportDocumentFileTypeTranslation:
                    title = TGLocalized(@"Passport.Identity.Translations");
                    comment = TGLocalized(@"Passport.Identity.TranslationsHelp");
                    break;
            }
            
            NSMutableArray *items = [[NSMutableArray alloc] init];
            [items addObject:[[TGHeaderCollectionItem alloc] initWithTitle:title]];
            
            TGButtonCollectionItem *uploadItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.Scans.Upload") action:@selector(uploadPressed:)];
            uploadItem.tag = type.integerValue;
            uploadItem.deselectAutomatically = true;
            [items addObject:uploadItem];
            
            [items addObject:[[TGCommentCollectionItem alloc] initWithText:comment]];
            
            TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:items];
            [self.menuSections addSection:section];
            
            _fileSections[type] = section;
        }
        
        if (existing)
        {
            _deleteItem = [[TGButtonCollectionItem alloc] initWithTitle:[self deleteTitle] action:@selector(deletePressed)];
            _deleteItem.deselectAutomatically = true;
            _deleteItem.alignment = NSTextAlignmentCenter;
            _deleteItem.titleColor = self.presentation.pallete.collectionMenuDestructiveColor;
            
            TGCollectionMenuSection *deleteSection = [[TGCollectionMenuSection alloc] initWithItems:@[_deleteItem]];
            [self.menuSections addSection:deleteSection];
        }
    }
    return self;
}

- (void)dealloc
{
    [_deleteDisposable dispose];
    [_uploadDisposables dispose];
}

- (void)setChanged:(bool)changed
{
    _changed = changed;
    
    if (changed && iosMajorVersion() >= 7)
        self.navigationController.interactivePopGestureRecognizer.enabled = false;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    __weak TGPassportDocumentController *weakSelf = self;
    ((TGNavigationController *)self.navigationController).shouldPopController = ^bool(__unused UIViewController *controller)
    {
        __strong TGPassportDocumentController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return true;
        
        if (!strongSelf->_changed)
            return true;
        
        [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"Passport.DiscardMessageTitle") message:TGLocalized(@"Passport.DiscardMessageDescription") customView:nil cancelButtonTitle:TGLocalized(@"Common.Cancel") doneButtonTitle:TGLocalized(@"Passport.DiscardMessageAction") completionBlock:^(bool done)
         {
             __strong TGPassportDocumentController *strongSelf = weakSelf;
             if (strongSelf == nil)
                 return;
             
             if (done)
             {
                 strongSelf->_changed = false;
                 dispatch_async(dispatch_get_main_queue(), ^
                 {
                     [strongSelf.navigationController popViewControllerAnimated:true];
                 });
             }
         }];
        
        return false;
    };
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    ((TGNavigationController *)self.navigationController).shouldPopController = nil;
    if (iosMajorVersion() >= 7)
        self.navigationController.interactivePopGestureRecognizer.enabled = true;
}

- (void)updateFileErrors
{
    [_fileSections enumerateKeysAndObjectsUsingBlock:^(NSNumber *nFileType, TGCollectionMenuSection *section, __unused BOOL *stop)
    {
        TGPassportDocumentFileType fileType = (TGPassportDocumentFileType)nFileType.integerValue;
        NSString *errorsString = fileType == TGPassportDocumentFileTypeGeneric ? [self.errors errorForTypeFiles:self.type].text : [self.errors errorForTypeTranslation:self.type].text;
        if (errorsString.length > 0 && _fileErrorItems[nFileType] == nil)
        {
            TGCommentCollectionItem *fileErrorsItem = [[TGCommentCollectionItem alloc] initWithText:errorsString];
            fileErrorsItem.sizeInset = -10.0f;
            fileErrorsItem.textColor = self.presentation.pallete.collectionMenuDestructiveColor;
            [section insertItem:fileErrorsItem atIndex:1];
            
            _fileErrorItems[nFileType] = fileErrorsItem;
        }
        else
        {
            TGCommentCollectionItem *fileErrorsItem = _fileErrorItems[nFileType];
            
            bool changed = ![fileErrorsItem.text isEqualToString:errorsString];
            fileErrorsItem.text = errorsString;
            fileErrorsItem.hidden = errorsString.length == 0;
            if (changed)
            {
                [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
                {
                    [self.collectionView.collectionViewLayout invalidateLayout];
                } completion:nil];
            }
        }
    }];
}

- (void)uploadPressed:(TGButtonCollectionItem *)item
{
    [self.view endEditing:true];
    
    NSNumber *nFileType = @(item.tag);
    NSUInteger currentCount = [(NSArray *)_files[nFileType] count] + [(NSArray *)_uploads[nFileType] count];
    
    __weak TGPassportDocumentController *weakSelf = self;
    [TGPassportAttachMenu presentWithContext:[TGLegacyComponentsContext shared] parentController:self menuController:nil title:nil intent:TGPassportAttachIntentMultiple uploadAction:^(SSignal *resultSignal, void (^dismissPicker)(void))
    {
        dismissPicker();
        
        [[[[resultSignal mapToSignal:^SSignal *(id value)
        {
            if ([value isKindOfClass:[NSDictionary class]])
            {
                return [SSignal single:value];
            }
            else if ([value isKindOfClass:[NSURL class]])
            {
                return [[TGPassportICloud fetchICloudFileWith:value] map:^id(NSURL *url)
                {
                    UIImage *image = [[UIImage alloc] initWithContentsOfFile:url.path];
                    
                    CGFloat maxSide = 2048.0f;
                    CGSize imageSize = TGFitSize(image.size, CGSizeMake(maxSide, maxSide));
                    UIImage *scaledImage = MAX(image.size.width, image.size.height) > maxSide ? TGScaleImageToPixelSize(image, imageSize) : image;
                    
                    CGFloat thumbnailSide = 60.0f * TGScreenScaling();
                    CGSize thumbnailSize = TGFitSize(scaledImage.size, CGSizeMake(thumbnailSide, thumbnailSide));
                    UIImage *thumbnailImage = TGScaleImageToPixelSize(scaledImage, thumbnailSize);
                    
                    return @{@"image": image, @"thumbnail": thumbnailImage };
                }];
            }
            return [SSignal complete];
        }] reduceLeft:[[NSMutableArray alloc] init] with:^NSMutableArray *(NSMutableArray *array, NSDictionary *next)
        {
            if (currentCount + array.count < 20)
                [array addObject:next];
            return array;
        }] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *next)
        {
            for (id desc in next)
            {
                TGPassportFileUpload *upload = [[TGPassportFileUpload alloc] initWithImage:desc[@"image"] thumbnailImage:desc[@"thumbnail"] date:(int32_t)[[NSDate date] timeIntervalSince1970]];
                [self enqueueFileUpload:upload type:(TGPassportDocumentFileType)item.tag];
            }
        }];
    } sourceView:self.view sourceRect:^CGRect{
        __strong TGPassportDocumentController *strongSelf = weakSelf;
        if (strongSelf != nil)
            return [item.view convertRect:item.view.bounds toView:strongSelf.view];
        return CGRectZero;
    } barButtonItem:nil];
}

- (NSString *)deleteTitle
{
    return TGLocalized(@"Passport.DeleteDocument");
}

- (NSString *)deleteConfirmationText
{
    return TGLocalized(@"Passport.DeleteDocumentConfirmation");
}

- (void)deletePressed
{
    [self.view endEditing:true];
    
    __weak TGPassportDocumentController *weakSelf = self;
    TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
    controller.dismissesByOutsideTap = true;
    controller.hasSwipeGesture = true;
    controller.narrowInLandscape = true;
    controller.permittedArrowDirections = UIPopoverArrowDirectionAny;
    controller.sourceRect = ^CGRect
    {
        __strong TGPassportDocumentController *strongSelf = weakSelf;
        if (strongSelf != nil)
            return [strongSelf->_deleteItem.view convertRect:strongSelf->_deleteItem.view.bounds toView:strongSelf.view];
        return CGRectZero;
    };
    
    TGMenuSheetTitleItemView *titleItem = [[TGMenuSheetTitleItemView alloc] initWithTitle:nil subtitle:[self deleteConfirmationText] solidSubtitle:true];
    
    __weak TGMenuSheetController *weakController = controller;
    TGMenuSheetButtonItemView *deleteItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Delete") type:TGMenuSheetButtonTypeDestructive action:^
    {
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongController dismissAnimated:true manual:true];
        
        __strong TGPassportDocumentController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf performDelete];
    }];
    
    TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
    {
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongController dismissAnimated:true manual:true];
    }];
    
    [controller setItemViews:@[ titleItem, deleteItem, cancelItem ]];
    
    [controller presentInViewController:self sourceView:self.view animated:true];
}

- (void)performDelete
{
    if (_deleteDisposable == nil)
        _deleteDisposable = [[SMetaDisposable alloc] init];
    
    _changed = false;
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow showWithDelay:0.45];
    
    NSTimeInterval startTime = CFAbsoluteTimeGetCurrent();
    
    __weak TGPassportDocumentController *weakSelf = self;
    [_deleteDisposable setDisposable:[[[TGPassportSignals deleteSecureValueTypes:@[@(_type)]] deliverOn:[SQueue mainQueue]] startWithNext:nil completed:^
    {
        __strong TGPassportDocumentController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [progressWindow dismiss:true];
        
        if (strongSelf.removalBlock != nil)
            strongSelf.removalBlock(strongSelf->_type);
        
        NSTimeInterval endTime = CFAbsoluteTimeGetCurrent();
        NSTimeInterval delay = 0.35 - (endTime - startTime);
        
        if (delay > 0)
        {
            TGDispatchAfter(delay, dispatch_get_main_queue(), ^
            {
                [strongSelf.navigationController popViewControllerAnimated:true];
            });
        }
        else
        {
            [strongSelf.navigationController popViewControllerAnimated:true];
        }
    }]];
}

#pragma mark -

- (void)enqueueFileUpload:(TGPassportFileUpload *)fileUpload type:(TGPassportDocumentFileType)type
{
    [self setChanged:true];
    
    NSArray *files = _files[@(type)];
    NSMutableArray *uploads = _uploads[@(type)];
    if (uploads == nil)
    {
        uploads = [[NSMutableArray alloc] init];
        _uploads[@(type)] = uploads;
    }
    [uploads addObject:fileUpload];
    
    if (type == TGPassportDocumentFileTypeGeneric)
        [_errors correctFilesErrorForType:self.type];
    else if (type == TGPassportDocumentFileTypeTranslation)
        [_errors correctTranslationErrorForType:self.type];
    [self updateFileErrors];
    
    NSInteger topIndex = [self filesTopIndex:type];
    
    SVariable *uploadProgress = [[SVariable alloc] init];
    SMetaDisposable *uploadDisposable = [[SMetaDisposable alloc] init];
    
    fileUpload.progress = uploadProgress;
    fileUpload.disposable = uploadDisposable;
    
    __weak TGPassportDocumentController *weakSelf = self;
    TGPassportFileCollectionItem *item = [[TGPassportFileCollectionItem alloc] initWithTitle:[NSString stringWithFormat:TGLocalized(@"Passport.Scans.ScanIndex"), [NSString stringWithFormat:@"%d", (int)files.count + (int)uploads.count]] action:^(TGPassportFileCollectionItem *fileItem)
    {
        __strong TGPassportDocumentController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf viewFile:fileItem.file];
    } removeRequested:^(TGPassportFileCollectionItem *fileItem)
    {
        __strong TGPassportDocumentController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf deleteFile:fileItem.file];
        if ([fileItem.file isKindOfClass:[TGPassportFileUpload class]])
            [uploadDisposable setDisposable:nil];
    }];
    item.file = fileUpload;
    item.progressSignal = uploadProgress.signal;
    item.deselectAutomatically = true;
    item.subtitle = [TGDateUtils stringForPreciseDate:fileUpload.date];
    [item setImageSignal:secureUploadThumbnailTransform(fileUpload.thumbnailImage)];
    
    [self.menuSections beginRecordingChanges];
    [self.menuSections insertItem:item toSection:[self.menuSections.sections indexOfObject:_fileSections[@(type)]] atIndex:topIndex + files.count + uploads.count - 1];
    [self.menuSections commitRecordedChanges:self.collectionView];
    
    [self beginNextUpload];
    
    [self updateUploadItem];
    [self checkInputValues];
}

- (void)beginNextUpload
{
    TGPassportFileUpload *fileUpload = nil;
    NSMutableArray *currentUploads = nil;
    NSNumber *currentType;
    for (NSNumber *type in _fileTypes)
    {
        currentUploads = _uploads[type];
        currentType = type;
        fileUpload = currentUploads.firstObject;
        if (fileUpload != nil)
            break;
    }
    if (_uploading || fileUpload == nil)
        return;
    
    _uploading = true;
    
    __weak TGPassportDocumentController *weakSelf = self;
    [fileUpload.disposable setDisposable:[[[[_settings.signal take:1] mapToSignal:^SSignal *(TGPassportPasswordRequest *request)
    {
        NSData *data = UIImageJPEGRepresentation(fileUpload.image, 0.89);
        NSData *thumbnailData = UIImageJPEGRepresentation(fileUpload.thumbnailImage, 0.6);
        return [TGPassportSignals uploadSecureData:data thumbnailData:thumbnailData secret:request.settings.secret];
    }] deliverOn:[SQueue mainQueue]] startWithNext:^(id next)
    {
        __strong TGPassportDocumentController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if ([next isKindOfClass:[NSNumber class]])
        {
            [fileUpload.progress set:[SSignal single:next]];
        }
        else if ([next isKindOfClass:[TGPassportFile class]])
        {
            TGPassportFile *file = (TGPassportFile *)next;
            
            NSArray *newFiles = [strongSelf->_files[currentType] arrayByAddingObject:file];
            newFiles = [newFiles sortedArrayUsingComparator:^NSComparisonResult(TGPassportFile *file1, TGPassportFile *file2)
            {
                return file1.date < file2.date ? NSOrderedAscending : NSOrderedDescending;
            }];
            
            NSMutableDictionary *updatedFiles = [strongSelf->_files mutableCopy];
            updatedFiles[currentType] = newFiles;
            strongSelf->_files = updatedFiles;
            
            [currentUploads removeObject:fileUpload];
            
            TGCollectionMenuSection *section = strongSelf->_fileSections[currentType];
            for (TGPassportFileCollectionItem *item in section.items)
            {
                if ([item isKindOfClass:[TGPassportFileCollectionItem class]] && [item.file isEqual:fileUpload])
                {
                    item.file = file;
                    item.progressSignal = [SSignal single:nil];
                    item.subtitle = [TGDateUtils stringForPreciseDate:file.date];
                    [item setImageSignal:secureMediaTransform(TGTelegraphInstance.mediaBox, file, true)];
            
                    break;
                }
            }
            
            strongSelf->_uploading = false;
            [strongSelf beginNextUpload];
            [strongSelf checkInputValues];
        }
    } completed:nil]];
    
    [_uploadDisposables add:fileUpload.disposable];
}

- (bool)shouldScanDocument
{
    return false;
}

- (void)applyScannedMRZ:(TGPassportMRZ *)__unused mrz ignoreDocument:(bool)__unused ignoreDocument
{
    
}

- (void)checkInputValues
{
    
}

- (bool)hasActiveUploads
{
    for (NSArray *uploads in _uploads.allValues)
    {
        if (uploads.count > 0)
            return true;
    }
    return false;
}

- (void)updateFiles
{
    [_fileSections enumerateKeysAndObjectsUsingBlock:^(NSNumber *nFileType, TGCollectionMenuSection *section, __unused BOOL *stop)
    {
        NSInteger topIndex = [self filesTopIndex:(TGPassportDocumentFileType)nFileType.integerValue];
        NSUInteger count = 2 + topIndex;
        while (section.items.count != count)
        {
            [section deleteItemAtIndex:topIndex];
        }
        
        __weak TGPassportDocumentController *weakSelf = self;
        NSInteger i = 0;
        for (TGPassportFile *file in _files[nFileType])
        {
            TGPassportFileCollectionItem *item = [[TGPassportFileCollectionItem alloc] initWithTitle:[NSString stringWithFormat:TGLocalized(@"Passport.Scans.ScanIndex"), [NSString stringWithFormat:@"%d", (int)i + 1]] action:^(TGPassportFileCollectionItem *fileItem)
            {
                __strong TGPassportDocumentController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf viewFile:fileItem.file];
            } removeRequested:^(TGPassportFileCollectionItem *fileItem)
            {
                __strong TGPassportDocumentController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf deleteFile:fileItem.file];
            }];
            item.file = file;
            item.deselectAutomatically = true;
            item.imageViewHidden = [file isEqual:_hiddenFile];
            [item setImageSignal:secureMediaTransform(TGTelegraphInstance.mediaBox, file, true)];
            item.progressSignal = [[TGTelegraphInstance.mediaBox resourceStatus:secureResource(file, false)] map:^id(MediaResourceStatus *status)
            {
                switch (status.status)
                {
                    case MediaResourceStatusRemote:
                        return @0.0;
                    case MediaResourceStatusFetching:
                        return @(status.progress);
                    default:
                        return nil;
                }
            }];
            
            TGPassportError *error = nil;
            if (nFileType.integerValue == TGPassportDocumentFileTypeGeneric)
                error = [_errors errorForType:self.type fileHash:[TGStringUtils stringByEncodingInBase64:file.fileHash]];
            else if (nFileType.integerValue == TGPassportDocumentFileTypeTranslation)
                error = [_errors errorForType:self.type translationFileHash:[TGStringUtils stringByEncodingInBase64:file.fileHash]];
            if (error.text.length > 0)
            {
                item.subtitle = error.text;
                item.isRequired = true;
            }
            else
            {
                item.subtitle = [TGDateUtils stringForPreciseDate:file.date];
                item.isRequired = false;
            }
            [section insertItem:item atIndex:topIndex + i];
            i++;
        }
        
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[self.menuSections.sections indexOfObject:section]]];
        
        [self updateUploadItem];
        [self checkInputValues];
    }];
}

- (void)updateUploadItem
{
    [_fileSections enumerateKeysAndObjectsUsingBlock:^(NSNumber *nFileType, TGCollectionMenuSection *section, __unused BOOL *stop)
    {
        NSUInteger count = [(NSArray *)_files[nFileType] count] + [(NSArray *)_uploads[nFileType] count];
        for (TGButtonCollectionItem *item in section.items)
        {
            if (![item isKindOfClass:[TGButtonCollectionItem class]])
                continue;
            
            item.title = count > 0 ? TGLocalized(@"Passport.Scans.UploadNew") : TGLocalized(@"Passport.Scans.Upload");
            item.enabled = count < 20;
        }
    }];
}

#pragma mark -

- (NSUInteger)filesTopIndex:(TGPassportDocumentFileType)type
{
    return _fileErrorItems[@(type)] ? 2 : 1;
}

- (void)deleteFile:(TGPassportFile *)file
{
    [self setChanged:true];
    
    if ([file isKindOfClass:[TGPassportFile class]])
    {
        for (NSNumber *type in _fileTypes)
        {
            NSArray *files = _files[type];
            NSUInteger index = [files indexOfObject:file];
            
            if (index != NSNotFound)
            {
                NSMutableArray *newFiles = [_files[type] mutableCopy];
                if (type.integerValue == TGPassportDocumentFileTypeGeneric)
                    [_errors correctFileErrorForType:self.type fileHash:[TGStringUtils stringByEncodingInBase64:file.fileHash]];
                else if (type.integerValue == TGPassportDocumentFileTypeTranslation)
                    [_errors correctTranslationErrorForType:self.type fileHash:[TGStringUtils stringByEncodingInBase64:file.fileHash]];

                [newFiles removeObjectAtIndex:index];

                NSMutableDictionary *updatedFiles = [_files mutableCopy];
                updatedFiles[type] = newFiles;
                _files = updatedFiles;
                
                break;
            }
        }
    }
    else if ([file isKindOfClass:[TGPassportFileUpload class]])
    {
        for (NSMutableArray *uploads in _uploads.allValues)
        {
            [uploads removeObject:file];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self updateUploadItem];
    });
    
    [self checkInputValues];
    
    [_fileSections enumerateKeysAndObjectsUsingBlock:^(NSNumber *nFileType, TGCollectionMenuSection *section, __unused BOOL *stop)
    {
        NSUInteger itemIndex = 0;
        for (TGPassportFileCollectionItem *item in section.items)
        {
            if ([item isKindOfClass:[TGPassportFileCollectionItem class]] && [item.file isEqual:file])
            {
                [self.menuSections beginRecordingChanges];
                [self.menuSections deleteItemFromSection:[self.menuSections.sections indexOfObject:section] atIndex:itemIndex];
                [self.menuSections commitRecordedChanges:self.collectionView];
                break;
            }
            itemIndex++;
        }
        
        NSUInteger topIndex = [self filesTopIndex:(TGPassportDocumentFileType)nFileType.integerValue];
        for (NSUInteger i = topIndex; i < section.items.count; i++)
        {
            TGPassportFileCollectionItem *collectionItem = section.items[i];
            if (![collectionItem isKindOfClass:[TGPassportFileCollectionItem class]])
                continue;
            
            NSInteger index = i - topIndex;
            collectionItem.title = [NSString stringWithFormat:TGLocalized(@"Passport.Scans.ScanIndex"), [NSString stringWithFormat:@"%d", (int)index + 1]];
        }
    }];
}

- (NSArray *)allFiles
{
    NSArray *genericFiles = _files[@(TGPassportDocumentFileTypeGeneric)] ?: @[];
    genericFiles = [genericFiles arrayByAddingObjectsFromArray:_uploads[@(TGPassportDocumentFileTypeGeneric)]];
    genericFiles = [genericFiles sortedArrayUsingComparator:^NSComparisonResult(TGPassportFile *file1, TGPassportFile *file2)
    {
        return file1.date < file2.date ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    NSArray *translationFiles = _files[@(TGPassportDocumentFileTypeTranslation)] ?: @[];
    translationFiles = [translationFiles arrayByAddingObjectsFromArray:_uploads[@(TGPassportDocumentFileTypeTranslation)]];
    translationFiles = [translationFiles sortedArrayUsingComparator:^NSComparisonResult(TGPassportFile *file1, TGPassportFile *file2)
    {
        return file1.date < file2.date ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    return [genericFiles arrayByAddingObjectsFromArray:translationFiles];
}

- (CGSize)thumbnailSizeForFile:(id)file
{
    for (TGCollectionMenuSection *section in _fileSections.allValues)
    {
        for (TGPassportFileCollectionItem *fileItem in section.items)
        {
            if (![fileItem isKindOfClass:[TGPassportFileCollectionItem class]])
                continue;
            
            if ([fileItem.file isEqual:file])
                return fileItem.imageSize;
        }
    }
    return CGSizeZero;
}

- (void)viewFile:(TGPassportFile *)file
{
    [self.view endEditing:true];
    
    __weak TGPassportDocumentController *weakSelf = self;
    TGModernGalleryController *galleryController = [[TGModernGalleryController alloc] initWithContext:[TGLegacyComponentsContext shared]];
    galleryController.asyncTransitionIn = true;
    TGPassportGalleryModel *model = [[TGPassportGalleryModel alloc] initWithFiles:self.allFiles centralFile:file];
    
    for (TGPassportGalleryItem *item in model.items)
    {
        if ([item.file isEqual:file])
        {
            item.contentSize = [self thumbnailSizeForFile:file];
            break;
        }
    }
    
    model.deleteFile = ^(TGPassportFile *fileToBeDeleted)
    {
        __strong TGPassportDocumentController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf deleteFile:fileToBeDeleted];
    };
    galleryController.model = model;
    
    __block id hiddenFile = nil;
    __block bool beganTransition = false;
    
    galleryController.itemFocused = ^(id<TGModernGalleryItem> item) {
        __strong TGPassportDocumentController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            id file = nil;
            if ([item isKindOfClass:[TGPassportGalleryItem class]]) {
                file = ((TGPassportGalleryItem *)item).file;
            }
            hiddenFile = file;
            if (beganTransition) {
                [strongSelf updateHiddenFile:file];
            }
        }
    };
    
    galleryController.beginTransitionIn = ^UIView *(id<TGModernGalleryItem> item, __unused TGModernGalleryItemView *itemView) {
        __strong TGPassportDocumentController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if ([item isKindOfClass:[TGPassportGalleryItem class]]) {
                TGPassportFileCollectionItem *collectionItem = [strongSelf itemForFile:((TGPassportGalleryItem *)item).file];
                [collectionItem.view.superview bringSubviewToFront:collectionItem.view];
                return collectionItem.imageView;
            }
        }
        
        return nil;
    };
    
    galleryController.startedTransitionIn = ^{
        __strong TGPassportDocumentController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            beganTransition = true;
            [strongSelf updateHiddenFile:hiddenFile];
        }
    };
    
    galleryController.beginTransitionOut = ^UIView *(id<TGModernGalleryItem> item, __unused TGModernGalleryItemView *itemView) {
        __strong TGPassportDocumentController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if ([item isKindOfClass:[TGPassportGalleryItem class]]) {
                TGPassportFileCollectionItem *collectionItem = [strongSelf itemForFile:((TGPassportGalleryItem *)item).file];
                [collectionItem.view.superview bringSubviewToFront:collectionItem.view];
                return collectionItem.imageView;
            }
        }
        
        return nil;
    };
    
    galleryController.completedTransitionOut = ^{
        __strong TGPassportDocumentController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf updateHiddenFile:nil];
        }
    };
    
    TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithManager:[[TGLegacyComponentsContext shared] makeOverlayWindowManager] parentController:self contentController:galleryController];
    controllerWindow.hidden = false;
}

- (TGPassportFileCollectionItem *)itemForFile:(TGPassportFile *)passportFile
{
    for (NSNumber *type in _fileTypes)
    {
        NSUInteger index = NSNotFound;
        NSUInteger i = 0;
        for (TGPassportFile *file in _files[type])
        {
            if ([file isEqual:passportFile])
            {
                index = i;
                break;
            }
            i++;
        }
        
        if (index != NSNotFound)
        {
            NSInteger topIndex = [self filesTopIndex:(TGPassportDocumentFileType)type.integerValue];
            TGCollectionMenuSection *section = _fileSections[type];
            if (section == nil)
                return nil;
            
            TGPassportFileCollectionItem *item = [section.items objectAtIndex:topIndex + index];
            return item;
        }
    }
    return nil;
}

- (void)updateHiddenFile:(TGPassportFile *)hiddenFile
{
    _hiddenFile = hiddenFile;
    
    for (TGCollectionMenuSection *section in _fileSections.allValues)
    {
        for (TGPassportFileCollectionItem *item in section.items)
        {
            if ([item isKindOfClass:[TGPassportFileCollectionItem class]])
                item.imageViewHidden = [item.file isEqual:hiddenFile];
        }
    }
}

- (BOOL)shouldAutorotate
{
    return false;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)presentUpdateAppAlert
{
    __weak TGPassportDocumentController *weakSelf = self;
    NSString *errorText = TGLocalized(@"Passport.UpdateRequiredError");
    [TGCustomAlertView presentAlertWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.NotNow") okButtonTitle:TGLocalized(@"Application.Update") completionBlock:^(__unused bool okButtonPressed)
    {
        __strong TGPassportDocumentController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf.navigationController popViewControllerAnimated:true];
        
        if (okButtonPressed)
        {
            NSNumber *appStoreId = @686449807;
#ifdef TELEGRAM_APPSTORE_ID
            appStoreId = TELEGRAM_APPSTORE_ID;
#endif
            NSURL *appStoreURL = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", appStoreId]];
            [[UIApplication sharedApplication] openURL:appStoreURL];
        }
    }];
}

@end
