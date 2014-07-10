#import "TGTelegraphProfileImageViewCompanion.h"

#import "ActionStage.h"
#import "SGraphListNode.h"

#import "TGTimelineItem.h"

#import "TGImageViewController.h"

#import "TGAppDelegate.h"
#import "TGTelegraph.h"

#import "TGForwardTargetController.h"

#import "TGImageSearchController.h"

#import "TGImageUtils.h"

#import "TGApplication.h"
#import "TGHacks.h"

#import "TGRemoteImageView.h"

#include <set>

@interface TGProfileImageItem ()

@property (nonatomic, strong) id itemId;
@property (nonatomic, strong) TGImageMediaAttachment *imageAttachment;

@end

@implementation TGProfileImageItem

- (id)initWithProfilePhoto:(TGImageMediaAttachment *)image
{
    self = [super init];
    if (self != nil)
    {
        _type = TGMediaItemTypePhoto;
        
        _imageAttachment = image;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGProfileImageItem *timelineMediaItem = [[TGProfileImageItem alloc] initWithProfilePhoto:_imageAttachment];
    timelineMediaItem.itemId = _itemId;
    
    return timelineMediaItem;
}

- (id)itemId
{
    if (_itemId == nil)
        _itemId = [[NSNumber alloc] initWithLongLong:_imageAttachment.imageId];
    
    return _itemId;
}

- (void)setExplicitItemId:(id)itemId
{
    _itemId = itemId;
}

- (int)date
{
    return (int)_imageAttachment.date;
}

- (int)authorUid
{
    return 0;
}

- (TGUser *)author
{
    return nil;
}

- (TGVideoMediaAttachment *)videoAttachment
{
    return nil;
}

- (UIImage *)immediateThumbnail
{
    return nil;
}

- (TGImageInfo *)imageInfo
{
    return _imageAttachment.imageInfo;
}

@end

@interface TGTelegraphProfileImageViewCompanion () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TGImagePickerControllerDelegate>

@property (nonatomic) int uid;

@property (nonatomic) bool loadingFirstItems;
@property (nonatomic) bool applyFirstItems;
@property (nonatomic) bool applyAnyItems;

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) TGProfileImageItem *initialItem;

@property (nonatomic, strong) UIActionSheet *currentActionSheet;

@end

@implementation TGTelegraphProfileImageViewCompanion

- (id)initWithUid:(int)uid photoItem:(id<TGMediaItem>)photoItem loadList:(bool)loadList
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
        _actionHandle.delegate = self;
        
        _uid = uid;
        
        _initialItem = [(TGProfileImageItem *)photoItem copy];
        _initialItem.imageAttachment = [_initialItem.imageAttachment copy];
        _initialItem.imageAttachment.date = INT_MAX;
        _items = [[NSMutableArray alloc] initWithObjects:_initialItem, nil];
        
        if (uid > 0 && loadList)
        {
            _loadingFirstItems = true;
            
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                [ActionStageInstance() watchForPath:[[NSString alloc] initWithFormat:@"/tg/profilePhotos/(%d)", uid] watcher:self];
                [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/profilePhotos/(%d,cached)", uid] options:@{@"peerId": @((int64_t)uid)} flags:0 watcher:self];
            }];
        }
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
    _currentActionSheet.delegate = nil;
}

- (bool)manualSavingEnabled
{
    return true;
}

- (bool)mediaSavingEnabled
{
    return true;
}

- (bool)deletionEnabled
{
    return _uid == TGTelegraphInstance.clientUserId;
}

- (bool)forwardingEnabled
{
    return false;
}

- (void)forceDismiss
{
    [TGAppDelegateInstance dismissContentController];
}

- (void)updateItems:(id)currentItemId
{
    if (_loadingFirstItems)
    {
        _applyFirstItems = true;
    }
    else
        [self _applyNewItems:_items currentItemId:[currentItemId longLongValue] applyCurrentItem:true];
    
    _applyAnyItems = true;
}

- (int)currentItemIndexInArray:(NSArray *)array
{
    TGImageViewController *imageViewController = _imageViewController;
    int64_t currentItemId = [[imageViewController currentItemId] longLongValue];
    
    int applyIndex = 0;
    if (currentItemId == 0)
    {
        NSString *firstImageUrl = [_initialItem.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
        
        int index = -1;
        for (TGImageMediaAttachment *imageAttachment in array)
        {
            index++;
            
            if ([imageAttachment.imageInfo containsSizeWithUrl:firstImageUrl])
            {
                applyIndex = index;
                
                break;
            }
        }
    }
    else
    {
        int index = -1;
        for (TGImageMediaAttachment *imageAttachment in array)
        {
            index++;
            
            if (currentItemId == imageAttachment.imageId)
            {
                applyIndex = index;
                
                break;
            }
        }
    }
    
    return applyIndex;
}

- (void)_applyNewItems:(NSArray *)newItems currentItemId:(int64_t)currentItemId applyCurrentItem:(bool)applyCurrentItem
{
    _items = [newItems mutableCopy];
    
    TGImageViewController *imageViewController = _imageViewController;
    
    if (applyCurrentItem)
        [imageViewController itemsChanged:_items totalCount:_items.count canLoadMore:false];
    else
        [imageViewController itemsChanged:_items totalCount:_items.count tryToStayOnItemId:true];
    
    if (applyCurrentItem)
    {
        int applyIndex = 0;
        if (currentItemId == 0)
        {
            NSString *firstImageUrl = [_initialItem.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
            
            int index = -1;
            for (TGProfileImageItem *imageItem in _items)
            {
                index++;
                
                if ([imageItem.imageAttachment.imageInfo containsSizeWithUrl:firstImageUrl])
                {
                    applyIndex = index;
                    
                    break;
                }
            }
        }
        else
        {
            int index = -1;
            for (TGProfileImageItem *imageItem in _items)
            {
                index++;
                
                if (currentItemId == [[imageItem itemId] longLongValue])
                {
                    applyIndex = index;
                    
                    break;
                }
            }
        }
        
        [imageViewController applyCurrentItem:applyIndex];
    }
    
    if (_items.count > 1)
    {
        [imageViewController setCustomTitle:nil];
    }
    else
        [imageViewController setCustomTitle:TGLocalized(@"Preview.ProfilePhotoTitle")];
}

- (void)loadMoreItems
{
}

- (void)preloadCount
{
    TGImageViewController *imageViewController = _imageViewController;
    
    if (_items.count > 1)
    {
        [imageViewController setCustomTitle:nil];
        [imageViewController positionInformationChanged:[self currentItemIndexInArray:_items] totalCount:_items.count];
    }
    else
        [imageViewController setCustomTitle:TGLocalized(@"Preview.ProfilePhotoTitle")];
}

- (void)deleteItem:(id)itemId
{
    int index = -1;
    for (TGProfileImageItem *item in _items)
    {
        index++;
        
        if ([[item itemId] isEqual:itemId])
        {
            int64_t imageId = item.imageAttachment.imageId;
            int64_t accessHash = item.imageAttachment.accessHash;
            
            if (imageId != 0 && accessHash != 0)
            {
                [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/deleteProfilePhoto/(%lld)", imageId] options:@{@"imageId": @(imageId), @"accessHash": @(accessHash)} flags:0 watcher:TGTelegraphInstance];
            }
            
            if (index == 0)
            {
                [_watcherHandle requestAction:@"deleteAvatar" options:nil];
                [_watcherHandle requestAction:@"closeImage" options:[[NSDictionary alloc] initWithObjectsAndKeys:_imageViewController, @"sender", @(true), @"forceSwipe", nil]];
            }
            
            break;
        }
    }
}

- (bool)shouldDeleteItemFromList:(id)itemId
{
    int index = -1;
    for (TGProfileImageItem *item in _items)
    {
        index++;
        
        if ([[item itemId] isEqual:itemId])
        {
            if (index != 0)
                return true;
            
            break;
        }
    }
    
    return false;
}

- (void)forwardItem:(id)__unused itemId
{
}

- (bool)editingEnabled
{
    return _uid == TGTelegraphInstance.clientUserId;
}

- (void)activateEditing
{
    if (_currentActionSheet != nil)
        _currentActionSheet.delegate = nil;
    
    _currentActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [_currentActionSheet addButtonWithTitle:TGLocalized(@"Common.TakePhoto")];
    [_currentActionSheet addButtonWithTitle:TGLocalized(@"Common.ChoosePhoto")];
    [_currentActionSheet addButtonWithTitle:TGLocalized(@"Conversation.SearchWebImages")];
    _currentActionSheet.cancelButtonIndex = [_currentActionSheet addButtonWithTitle:TGLocalized(@"Common.Cancel")];
    TGImageViewController *imageViewController = _imageViewController;
    [_currentActionSheet showInView:imageViewController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == _currentActionSheet)
        _currentActionSheet = nil;
    
    actionSheet.delegate = nil;
    
    TGImageViewController *imageViewController = _imageViewController;
    
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        if (buttonIndex == 0)
        {
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                return;
            
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.allowsEditing = true;
            imagePicker.delegate = self;
            
            [(TGApplication *)[UIApplication sharedApplication] setProcessStatusBarHiddenRequests:true];
            
            [imageViewController presentViewController:imagePicker animated:true completion:nil];
            
            [imageViewController acquireRotationLock];
        }
        else if (buttonIndex == 1 || buttonIndex == 2)
        {
            NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
            
            TGImageSearchController *searchController = [[TGImageSearchController alloc] initWithAvatarSelection:true];
            searchController.autoActivateSearch = buttonIndex == 2;
            searchController.delegate = self;
            [viewControllers addObject:searchController];
            
            if (buttonIndex == 1)
            {
                TGImagePickerController *imagePicker = [[TGImagePickerController alloc] initWithGroupUrl:nil groupTitle:nil avatarSelection:true];
                imagePicker.delegate = self;
                [viewControllers addObject:imagePicker];
            }
            
            UIViewController *topViewController = [viewControllers lastObject];
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:true];
            
            TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:viewControllers];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                navigationController.restrictLandscape = true;
            else
            {
                navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            
            [topViewController view];
            
            [imageViewController presentViewController:navigationController animated:true completion:nil];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [navigationController acquireRotationLock];
        }
    }
}

- (void)imagePickerController:(TGImagePickerController *)__unused imagePicker didFinishPickingWithAssets:(NSArray *)assets
{
    TGImageViewController *imageViewController = _imageViewController;
    
    if (assets.count != 0)
    {
        for (id object in assets)
        {
            if ([object isKindOfClass:[UIImage class]])
            {
                [self _updateProfileImage:object];
            }
        }
    }
    else
    {
        [imageViewController dismissViewControllerAnimated:true completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)__unused picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    CGRect cropRect = [[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
    if (ABS(cropRect.size.width - cropRect.size.height) > FLT_EPSILON)
    {
        if (cropRect.size.width < cropRect.size.height)
        {
            cropRect.origin.x -= (cropRect.size.height - cropRect.size.width) / 2;
            cropRect.size.width = cropRect.size.height;
        }
        else
        {
            cropRect.origin.y -= (cropRect.size.width - cropRect.size.height) / 2;
            cropRect.size.height = cropRect.size.width;
        }
    }
    
    UIImage *image = TGFixOrientationAndCrop([info objectForKey:UIImagePickerControllerOriginalImage], cropRect, CGSizeMake(600, 600));
    
    [self _updateProfileImage:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)__unused picker
{
    TGImageViewController *imageViewController = _imageViewController;
    
    [imageViewController dismissViewControllerAnimated:true completion:nil];
    
    [(TGApplication *)[UIApplication sharedApplication] setProcessStatusBarHiddenRequests:false];
    
    [imageViewController releaseRotationLock];
}

- (void)_updateProfileImage:(UIImage *)image
{
    [TGAppDelegateInstance.settingsController _updateProfileImage:image];
    
    TGImageViewController *imageViewController = _imageViewController;
    imageViewController.view.hidden = true;
    
    [imageViewController releaseRotationLock];
    
    [imageViewController dismissViewControllerAnimated:true completion:^
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [TGAppDelegateInstance dismissContentController];
            [TGHacks setApplicationStatusBarAlpha:1.0f];
        });
        
        [(TGApplication *)[UIApplication sharedApplication] setProcessStatusBarHiddenRequests:false];
    }];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path hasPrefix:@"/tg/profilePhotos/"])
    {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/tg/profilePhotos/"])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            _loadingFirstItems = false;
            
            if (status == ASStatusSuccess)
            {
                NSMutableArray *itemsRaw = [result mutableCopy];
                
                NSMutableArray *imageItems = [[NSMutableArray alloc] initWithCapacity:itemsRaw.count];
                for (TGImageMediaAttachment *imageAttachment in itemsRaw)
                {
                    [imageItems addObject:[[TGProfileImageItem alloc] initWithProfilePhoto:imageAttachment]];
                }
                
                NSString *firstImageUrl = [_initialItem.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                
                bool found = false;
                
                for (TGProfileImageItem *imageItem in imageItems)
                {
                    if ([[imageItem imageInfo] containsSizeWithUrl:firstImageUrl])
                    {
                        found = true;
                        break;
                    }
                }
                
                if (!found)
                    [imageItems addObject:_initialItem];
                
                [imageItems sortUsingComparator:^NSComparisonResult(TGProfileImageItem *image1, TGProfileImageItem *image2)
                {
                    if ([image1 date] > [image2 date])
                        return NSOrderedAscending;
                    else if ([image1 date] < [image2 date])
                        return NSOrderedDescending;
                    
                    return NSOrderedSame;
                }];
                
                bool changed = false;
                
                if (imageItems.count == _items.count)
                {
                    int index = -1;
                    for (TGProfileImageItem *item1 in imageItems)
                    {
                        index++;
                        
                        TGProfileImageItem *item2 = _items[index];
                        
                        if (![[item1 itemId] isEqual:[item2 itemId]])
                        {
                            changed = true;
                            break;
                        }
                    }
                }
                else
                    changed = true;
                
                if (changed)
                {
                    TGImageViewController *imageViewController = _imageViewController;
                    
                    if (_applyFirstItems)
                        [self _applyNewItems:imageItems currentItemId:[[imageViewController currentItemId] longLongValue] applyCurrentItem:true];
                    else if (_applyAnyItems)
                        [self _applyNewItems:imageItems currentItemId:[[imageViewController currentItemId] longLongValue] applyCurrentItem:false];
                    else
                    {
                        _items = imageItems;
                        
                        if (_items.count > 1)
                        {
                            [imageViewController setCustomTitle:nil];
                            [imageViewController positionInformationChanged:[self currentItemIndexInArray:imageItems] totalCount:_items.count];
                        }
                        else
                            [imageViewController setCustomTitle:TGLocalized(@"Preview.ProfilePhotoTitle")];
                    }
                }
            }
            
            _applyFirstItems = false;
        });
    }
}

@end
