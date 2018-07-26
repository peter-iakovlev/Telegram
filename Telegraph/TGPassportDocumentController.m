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
    bool _uploading;
    SDisposableSet *_uploadDisposables;
    SMetaDisposable *_deleteDisposable;
    
    TGButtonCollectionItem *_uploadItem;
    TGCommentCollectionItem *_fileErrorsItem;
}

@property (nonatomic, strong) NSMutableArray *uploads;

@end

@implementation TGPassportDocumentController

- (instancetype)initWithSettings:(SVariable *)settings files:(NSArray *)files inhibitFiles:(bool)inhibitFiles errors:(TGPassportErrors *)errors existing:(bool)existing
{
    self = [super init];
    if (self != nil)
    {
        _settings = settings;
        _files = files ?: [[NSArray alloc] init];
        _uploads = [[NSMutableArray alloc] init];
        _errors = [errors copy];
                
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        if (!inhibitFiles)
        {
            [items addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.Scans")]];
            
            _uploadItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.Scans.UploadNew") action:@selector(uploadPressed)];
            _uploadItem.deselectAutomatically = true;
            [items addObject:_uploadItem];
            
            _scansSection = [[TGCollectionMenuSection alloc] initWithItems:items];
            [self.menuSections addSection:_scansSection];
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
}

- (void)updateFileErrors
{
    NSString *errorsString = [self.errors errorForTypeFiles:self.type].text;
    if (errorsString.length > 0 && _fileErrorsItem == nil)
    {
        _fileErrorsItem = [[TGCommentCollectionItem alloc] initWithText:errorsString];
        _fileErrorsItem.sizeInset = -10.0f;
        _fileErrorsItem.textColor = self.presentation.pallete.collectionMenuDestructiveColor;
        [_scansSection insertItem:_fileErrorsItem atIndex:1];
    }
    else
    {
        bool changed = ![_fileErrorsItem.text isEqualToString:errorsString];
        _fileErrorsItem.text = errorsString;
        _fileErrorsItem.hidden = errorsString.length == 0;
        
        if (changed)
        {
            [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
            {
                [self.collectionView.collectionViewLayout invalidateLayout];
            } completion:nil];
        }
    }
}

- (void)uploadPressed
{
    [self.view endEditing:true];
    
    __weak TGPassportDocumentController *weakSelf = self;
    [TGPassportAttachMenu presentWithContext:[TGLegacyComponentsContext shared] parentController:self menuController:nil title:nil intent:TGPassportAttachIntentMultiple uploadAction:^(SSignal *resultSignal, void (^dismissPicker)(void))
    {
        dismissPicker();
        
        [[[resultSignal mapToSignal:^SSignal *(id value)
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
        }] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *next)
        {
            TGPassportFileUpload *upload = [[TGPassportFileUpload alloc] initWithImage:next[@"image"] thumbnailImage:next[@"thumbnail"] date:(int32_t)[[NSDate date] timeIntervalSince1970]];
            [self enqueueFileUpload:upload];
        }];
    } sourceView:self.view sourceRect:^CGRect{
        __strong TGPassportDocumentController *strongSelf = weakSelf;
        if (strongSelf != nil)
            return [strongSelf->_uploadItem.view convertRect:strongSelf->_uploadItem.view.bounds toView:strongSelf.view];
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

- (void)enqueueFileUpload:(TGPassportFileUpload *)fileUpload
{
    _changed = true;
    [_uploads addObject:fileUpload];
    
    [_errors correctFilesErrorForType:self.type];
    [self updateFileErrors];
    
    NSInteger topIndex = [self scansTopIndex];
    
    SVariable *uploadProgress = [[SVariable alloc] init];
    SMetaDisposable *uploadDisposable = [[SMetaDisposable alloc] init];
    
    fileUpload.progress = uploadProgress;
    fileUpload.disposable = uploadDisposable;
    
    __weak TGPassportDocumentController *weakSelf = self;
    TGPassportFileCollectionItem *item = [[TGPassportFileCollectionItem alloc] initWithTitle:[NSString stringWithFormat:TGLocalized(@"Passport.Scans.ScanIndex"), [NSString stringWithFormat:@"%d", (int)_files.count + (int)_uploads.count]] action:^(TGPassportFileCollectionItem *fileItem)
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
    [self.menuSections insertItem:item toSection:[self.menuSections.sections indexOfObject:_scansSection] atIndex:topIndex + _files.count + _uploads.count - 1];
    [self.menuSections commitRecordedChanges:self.collectionView];
    
    [self beginNextUpload];
    
    [self updateUploadItem];
    [self checkInputValues];
}

- (void)beginNextUpload
{
    TGPassportFileUpload *fileUpload = _uploads.firstObject;
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
            
            NSArray *updatedFiles = [strongSelf->_files arrayByAddingObject:file];
            updatedFiles = [updatedFiles sortedArrayUsingComparator:^NSComparisonResult(TGPassportFile *file1, TGPassportFile *file2)
            {
                return file1.date < file2.date ? NSOrderedAscending : NSOrderedDescending;
            }];
            strongSelf->_files = updatedFiles;
            [strongSelf->_uploads removeObject:fileUpload];
            
            for (TGPassportFileCollectionItem *item in [strongSelf scansSection].items)
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

- (void)updateFiles
{
    if (_scansSection == nil)
        return;
    
    NSInteger topIndex = [self scansTopIndex];
    NSUInteger count = 2 + topIndex;
    while (_scansSection.items.count != count)
    {
        [_scansSection deleteItemAtIndex:topIndex];
    }
    
    __weak TGPassportDocumentController *weakSelf = self;
    NSInteger i = 0;
    for (TGPassportFile *file in _files)
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
        
        TGPassportError *error = [_errors errorForType:self.type fileHash:[TGStringUtils stringByEncodingInBase64:file.fileHash]];
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
        [_scansSection insertItem:item atIndex:topIndex + i];
        i++;
    }
    
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[self.menuSections.sections indexOfObject:_scansSection]]];
    
    [self updateUploadItem];
    [self checkInputValues];
}

- (void)updateUploadItem
{
    NSUInteger count = _files.count + _uploads.count;
    _uploadItem.title = count > 0 ? TGLocalized(@"Passport.Scans.UploadNew") : TGLocalized(@"Passport.Scans.Upload");
    _uploadItem.enabled = count < 20;
}

#pragma mark -

- (TGCollectionMenuSection *)scansSection
{
    NSUInteger section = [self.menuSections.sections indexOfObject:_scansSection];
    if (section == NSNotFound)
        return nil;
    
    return self.menuSections.sections[section];
}

- (NSUInteger)scansTopIndex
{
    return _fileErrorsItem != nil ? 2 : 1;
}

- (void)deleteFile:(TGPassportFile *)file
{
    _changed = true;
    if ([file isKindOfClass:[TGPassportFile class]])
    {
        NSMutableArray *updatedFiles = [_files mutableCopy];
        NSUInteger index = [updatedFiles indexOfObject:file];
        if (index == NSNotFound)
            return;
        
        [_errors correctFileErrorForType:self.type fileHash:[TGStringUtils stringByEncodingInBase64:file.fileHash]];
        
        [updatedFiles removeObjectAtIndex:index];
        _files = updatedFiles;
    }
    else if ([file isKindOfClass:[TGPassportFileUpload class]])
    {
        [_uploads removeObject:file];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self updateUploadItem];
    });
    
    [self checkInputValues];
    
    if (_scansSection != nil)
    {
        NSUInteger itemIndex = 0;
        for (TGPassportFileCollectionItem *item in [self scansSection].items)
        {
            if ([item isKindOfClass:[TGPassportFileCollectionItem class]] && [item.file isEqual:file])
            {
                [self.menuSections beginRecordingChanges];
                [self.menuSections deleteItemFromSection:[self.menuSections.sections indexOfObject:_scansSection] atIndex:itemIndex];
                [self.menuSections commitRecordedChanges:self.collectionView];
                break;
            }
            itemIndex++;
        }

        NSUInteger topIndex = [self scansTopIndex];
        for (NSUInteger i = topIndex; i < _scansSection.items.count - topIndex; i++)
        {
            NSInteger index = i - topIndex;
            TGPassportFileCollectionItem *collectionItem = _scansSection.items[i];
            collectionItem.title = [NSString stringWithFormat:TGLocalized(@"Passport.Scans.ScanIndex"), [NSString stringWithFormat:@"%d", (int)index + 1]];
        }
    }
}

- (NSArray *)allFiles
{
    NSArray *allFiles = [_files arrayByAddingObjectsFromArray:_uploads];
    allFiles = [allFiles sortedArrayUsingComparator:^NSComparisonResult(TGPassportFile *file1, TGPassportFile *file2)
    {
        return file1.date < file2.date ? NSOrderedAscending : NSOrderedDescending;
    }];
    return allFiles;
}

- (CGSize)thumbnailSizeForFile:(id)file
{
    for (TGPassportFileCollectionItem *fileItem in _scansSection.items)
    {
        if (![fileItem isKindOfClass:[TGPassportFileCollectionItem class]])
            continue;
        
        if ([fileItem.file isEqual:file])
            return fileItem.imageSize;
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
    NSUInteger index = NSNotFound;
    NSUInteger i = 0;
    for (TGPassportFile *file in _files)
    {
        if ([file isEqual:passportFile])
        {
            index = i;
            break;
        }
        i++;
    }
    
    if (index == NSNotFound)
        return nil;
    
    NSInteger topIndex = [self scansTopIndex];
    TGPassportFileCollectionItem *item = [_scansSection.items objectAtIndex:topIndex + index];
    return item;
}

- (void)updateHiddenFile:(TGPassportFile *)hiddenFile
{
    _hiddenFile = hiddenFile;
    
    for (TGPassportFileCollectionItem *item in _scansSection.items)
    {
        if ([item isKindOfClass:[TGPassportFileCollectionItem class]])
            item.imageViewHidden = [item.file isEqual:hiddenFile];
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

@end
