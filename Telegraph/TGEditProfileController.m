#import "TGEditProfileController.h"

#import <LegacyComponents/LegacyComponents.h>
#import <LegacyComponents/ASWatcher.h>
#import <LegacyComponents/TGProgressWindow.h>

#import "TGLegacyComponentsContext.h"
#import "TGTelegraph.h"
#import "TGAppDelegate.h"
#import "TGInterfaceManager.h"

#import "TGTimelineUploadPhotoRequestBuilder.h"
#import "TGDeleteProfilePhotoActor.h"
#import "TGTimelineItem.h"

#import "TGUserSignal.h"
#import "TGAccountSignals.h"

#import "TGActionSheet.h"
#import "TGAlertView.h"

#import "TGAccountInfoCollectionItem.h"
#import "TGCollectionMultilineInputItem.h"
#import "TGVariantCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGChangePhoneNumberHelpController.h"
#import "TGUsernameController.h"
#import "TGWebSearchController.h"

#import <LegacyComponents/TGModernGalleryController.h>
#import "TGProfileUserAvatarGalleryModel.h"
#import "TGProfileUserAvatarGalleryItem.h"

#import "TGPresentation.h"

@interface TGEditProfileController () <ASWatcher>
{
    int32_t _uid;
    NSString *_initialAbout;
    
    UIBarButtonItem *_doneItem;
    
    id<SDisposable> _updatedCachedDataDisposable;
    id<SDisposable> _currentAboutDisposable;
    SMetaDisposable *_updateAboutDisposable;
    
    TGAccountInfoCollectionItem *_profileDataItem;
    
    TGCollectionMenuSection *_aboutSection;
    TGCollectionMultilineInputItem *_inputItem;
    
    TGVariantCollectionItem *_usernameItem;
    TGVariantCollectionItem *_phoneNumberItem;
    
    TGMediaAvatarMenuMixin *_avatarMixin;
}

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, strong) TGProgressWindow *progressWindow;

@end

@implementation TGEditProfileController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        [ActionStageInstance() watchForPaths:@[
            @"/tg/userdatachanges",
            @"/tg/userpresencechanges",
        ] watcher:self];
        
        _uid = TGTelegraphInstance.clientUserId;
        self.title = TGLocalized(@"EditProfile.Title");
        _doneItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
        [self setRightBarButtonItem:_doneItem];
        
        TGUser *user = [TGDatabaseInstance() loadUser:_uid];
        
        _profileDataItem = [[TGAccountInfoCollectionItem alloc] init];
        [_profileDataItem setUser:user animated:false];
        _profileDataItem.showCameraIcon = true;
        _profileDataItem.disableAvatarPlaceholder = true;
        [_profileDataItem setEditing:true animated:false];
        _profileDataItem.interfaceHandle = _actionHandle;
        
        TGCommentCollectionItem *commentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"EditProfile.NameAndPhotoHelp")];
        commentItem.topInset = 1.0f;
        
        TGCollectionMenuSection *topSection = [[TGCollectionMenuSection alloc] initWithItems:@[_profileDataItem, commentItem]];
        [self.menuSections addSection:topSection];
        
        _inputItem = [[TGCollectionMultilineInputItem alloc] init];
        _inputItem.maxLength = 70;
        _inputItem.disallowNewLines = true;
        _inputItem.placeholder = TGLocalized(@"UserInfo.About.Placeholder");
        _inputItem.showRemainingCount = true;
        _inputItem.returnKeyType = UIReturnKeyDone;
        __weak TGEditProfileController *weakSelf = self;
        _inputItem.heightChanged = ^ {
            __strong TGEditProfileController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf.collectionLayout invalidateLayout];
                [strongSelf.collectionView layoutSubviews];
            }
        };
        _inputItem.returned = ^ {
            __strong TGEditProfileController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf donePressed];
            }
        };
        
        commentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Settings.About.Help")];
        commentItem.topInset = 1.0f;
        
        _aboutSection = [[TGCollectionMenuSection alloc] initWithItems:@[_inputItem, commentItem]];
        [self.menuSections addSection:_aboutSection];
        
        _usernameItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.Username") action:@selector(usernamePressed)];
        _phoneNumberItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.PhoneNumber") action:@selector(phoneNumberPressed)];
        
        NSString *username = user.userName.length == 0 ? TGLocalized(@"Settings.UsernameEmpty") : [[NSString alloc] initWithFormat:@"@%@", user.userName];
        _usernameItem.variant = username;
        
        NSString *phoneNumber = user.phoneNumber.length == 0 ? @"" : [TGPhoneUtils formatPhone:user.phoneNumber forceInternational:true];
        _phoneNumberItem.variant = phoneNumber;
        
        TGCollectionMenuSection *credentialsSection = [[TGCollectionMenuSection alloc] initWithItems:@[_phoneNumberItem, _usernameItem]];
        [self.menuSections addSection:credentialsSection];
        
        TGButtonCollectionItem *logoutItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.Logout") action:@selector(logoutPressed)];
        logoutItem.alignment = NSTextAlignmentCenter;
        logoutItem.titleColor = TGPresentation.current.pallete.collectionMenuDestructiveColor;
        logoutItem.deselectAutomatically = true;
        
        NSMutableArray *logoutSectionItems = [[NSMutableArray alloc] init];
        [logoutSectionItems addObject:logoutItem];
        
        TGCollectionMenuSection *logoutSection = [[TGCollectionMenuSection alloc] initWithItems:@[logoutItem]];
        [self.menuSections addSection:logoutSection];
        
        [ActionStageInstance() watchForPath:@"/tg/loggedOut" watcher:self];
    }
    return self;
}

- (void)dealloc {
    [_updateAboutDisposable dispose];
    [_currentAboutDisposable dispose];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _updatedCachedDataDisposable = [[TGUserSignal updatedUserCachedDataWithUserId:TGTelegraphInstance.clientUserId] startWithNext:nil];
    
     __weak TGEditProfileController *weakSelf = self;
    _currentAboutDisposable = [[[[[[TGDatabaseInstance() userCachedData:TGTelegraphInstance.clientUserId] map:^NSString *(TGCachedUserData *data)
    {
        return data.about ?: @"";
    }] ignoreRepeated] take:2] deliverOn:[SQueue mainQueue]] startWithNext:^(NSString *about)
    {
        __strong TGEditProfileController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            strongSelf->_initialAbout = about;
            
            [strongSelf->_inputItem setText:about];
            [strongSelf.collectionLayout invalidateLayout];
            [strongSelf.collectionView layoutSubviews];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        NSArray *uploadActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/timeline/@/uploadPhoto/@" prefix:[[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/uploadPhoto/", _uid] watcher:self];
        NSArray *deleteActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/timeline/@/deleteAvatar/@" prefix:[[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/deleteAvatar/", _uid] watcher:self];
        if (uploadActions.count != 0)
        {
            TGTimelineUploadPhotoRequestBuilder *actor = (TGTimelineUploadPhotoRequestBuilder *)[ActionStageInstance() executingActorWithPath:uploadActions.lastObject];
            if (actor != nil)
            {
                TGDispatchOnMainThread(^
                {
                    [_profileDataItem setUpdatingAvatar:actor.currentPhoto hasUpdatingAvatar:true];
                });
            }
        }
        else if (deleteActions.count != 0)
        {
            TGDeleteProfilePhotoActor *actor = (TGDeleteProfilePhotoActor *)[ActionStageInstance() executingActorWithPath:deleteActions.lastObject];
            if (actor != nil)
            {
                TGDispatchOnMainThread(^
                {
                    [_profileDataItem setUpdatingAvatar:nil hasUpdatingAvatar:true];
                });
            }
        }
    }];
}

- (void)donePressed
{
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow show:true];
    
    TGUser *user = [TGDatabaseInstance() loadUser:_uid];
    if (!TGStringCompare(user.firstName, [_profileDataItem editingFirstName]) || !TGStringCompare(user.lastName, [_profileDataItem editingLastName]))
    {
        [_profileDataItem setUpdatingFirstName:[_profileDataItem editingFirstName] updatingLastName:[_profileDataItem editingLastName]];
        
        static int actionId = 0;
        NSString *action = [[NSString alloc] initWithFormat:@"/tg/changeUserName/(%d)", actionId++];
        NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:[_profileDataItem editingFirstName], @"firstName", [_profileDataItem editingLastName], @"lastName", nil];
        [ActionStageInstance() requestActor:action options:options flags:0 watcher:self];
    }
    
    NSString *text = [_inputItem.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![text isEqualToString:_initialAbout])
    {
        [_updateAboutDisposable setDisposable:[[[[TGAccountSignals updateAbout:text] deliverOn:[SQueue mainQueue]] onDispose:^
        {
            [progressWindow dismiss:true];
        }] startWithNext:nil error:^(__unused id error) {
            [[[TGAlertView alloc] initWithTitle:TGLocalized(@"Login.UnknownError") message:nil cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        } completed:^{
        }]];
    }
    
    [self.navigationController popViewControllerAnimated:true];
}

- (void)viewProfilePhoto
{
    TGUser *user = [TGDatabaseInstance() loadUser:_uid];
    
    if ([_profileDataItem hasUpdatingAvatar])
    {
        TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:nil actions:@[
                                                                                        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"GroupInfo.SetGroupPhotoStop") action:@"stop" type:TGActionSheetActionTypeDestructive],
                                                                                        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel],
                                                                                        ] actionBlock:^(id target, NSString *action)
        {
            if ([action isEqualToString:@"stop"])
            {
                [(TGEditProfileController *)target _commitCancelAvatarUpdate];
            }
        } target:self];
        [actionSheet showInView:self.view];
    }
    else
    {
        TGRemoteImageView *avatarView = [_profileDataItem visibleAvatarView];
        
        if (user != nil && user.photoUrlBig != nil && avatarView.currentImage != nil)
        {
            TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] initWithContext:[TGLegacyComponentsContext shared]];
            
            TGProfileUserAvatarGalleryModel *model = [[TGProfileUserAvatarGalleryModel alloc] initWithCurrentAvatarLegacyThumbnailImageUri:user.photoUrlSmall currentAvatarLegacyImageUri:user.photoUrlBig currentAvatarImageSize:CGSizeMake(640.0f, 640.0f)];
            
            __weak TGEditProfileController *weakSelf = self;
            model.deleteCurrentAvatar = ^
            {
                __strong TGEditProfileController *strongSelf = weakSelf;
                [strongSelf _commitDeleteAvatar];
            };
            
            modernGallery.model = model;
            
            modernGallery.itemFocused = ^(id<TGModernGalleryItem> item)
            {
                __strong TGEditProfileController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
                    {
                        if (((TGUserAvatarGalleryItem *)item).isCurrent)
                        {
                            [strongSelf->_profileDataItem setAvatarHidden:true animated:false];
                        }
                        else
                            [strongSelf->_profileDataItem setAvatarHidden:false animated:false];
                    }
                }
            };
            
            modernGallery.beginTransitionIn = ^UIView *(id<TGModernGalleryItem> item, __unused TGModernGalleryItemView *itemView)
            {
                __strong TGEditProfileController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
                    {
                        if (((TGUserAvatarGalleryItem *)item).isCurrent)
                        {
                            return strongSelf->_profileDataItem.visibleAvatarView;
                        }
                    }
                }
                
                return nil;
            };
            
            modernGallery.beginTransitionOut = ^UIView *(id<TGModernGalleryItem> item, __unused TGModernGalleryItemView *itemView)
            {
                __strong TGEditProfileController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
                    {
                        if (((TGUserAvatarGalleryItem *)item).isCurrent)
                        {
                            return strongSelf->_profileDataItem.visibleAvatarView;
                        }
                    }
                }
                
                return nil;
            };
            
            modernGallery.completedTransitionOut = ^
            {
                __strong TGEditProfileController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    [strongSelf->_profileDataItem setAvatarHidden:false animated:true];
                }
            };
            
            TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithManager:[[TGLegacyComponentsContext shared] makeOverlayWindowManager] parentController:self contentController:modernGallery];
            controllerWindow.hidden = false;
        }
    }
}

- (void)setProfilePhotoPressed
{
    TGUser *user = [TGDatabaseInstance() loadUser:_uid];
    
    __weak TGEditProfileController *weakSelf = self;
    _avatarMixin = [[TGMediaAvatarMenuMixin alloc] initWithContext:[TGLegacyComponentsContext shared] parentController:self hasDeleteButton:true hasViewButton:user.photoUrlSmall.length > 0 personalPhoto:true saveEditedPhotos:TGAppDelegateInstance.saveEditedPhotos saveCapturedMedia:TGAppDelegateInstance.saveCapturedMedia];
    _avatarMixin.didFinishWithImage = ^(UIImage *image)
    {
        __strong TGEditProfileController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _updateProfileImage:image];
        strongSelf->_avatarMixin = nil;
    };
    _avatarMixin.didFinishWithDelete = ^
    {
        __strong TGEditProfileController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _commitDeleteAvatar];
        strongSelf->_avatarMixin = nil;
    };
    _avatarMixin.didFinishWithView = ^
    {
        __strong TGEditProfileController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf viewProfilePhoto];
        strongSelf->_avatarMixin = nil;
    };
    _avatarMixin.didDismiss = ^
    {
        __strong TGEditProfileController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_avatarMixin = nil;
    };
    _avatarMixin.requestSearchController = ^TGViewController *(TGMediaAssetsController *assetsController) {
        TGWebSearchController *searchController = [[TGWebSearchController alloc] initWithContext:[TGLegacyComponentsContext shared] forAvatarSelection:true embedded:true allowGrouping:false];
        
        __weak TGMediaAssetsController *weakAssetsController = assetsController;
        __weak TGWebSearchController *weakController = searchController;
        searchController.avatarCompletionBlock = ^(UIImage *image) {
            __strong TGMediaAssetsController *strongAssetsController = weakAssetsController;
            if (strongAssetsController.avatarCompletionBlock == nil)
                return;
            
            strongAssetsController.avatarCompletionBlock(image);
        };
        searchController.dismiss = ^
        {
            __strong TGWebSearchController *strongController = weakController;
            if (strongController == nil)
                return;
            
            [strongController dismissEmbeddedAnimated:true];
        };
        searchController.parentNavigationController = assetsController;
        [searchController presentEmbeddedInController:assetsController animated:true];
        
        return searchController;
    };
    [_avatarMixin present];
}

- (void)phoneNumberPressed
{
    TGChangePhoneNumberHelpController *phoneNumberController = [[TGChangePhoneNumberHelpController alloc] init];
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[phoneNumberController]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        navigationController.restrictLandscape = true;
    else
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)usernamePressed
{
    TGUsernameController *usernameController = [[TGUsernameController alloc] init];
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[usernameController]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        navigationController.restrictLandscape = false;
    else
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)actionStageActionRequested:(NSString *)action options:(id)__unused options
{
    if ([action isEqualToString:@"avatarTapped"])
    {
        if ([_profileDataItem hasUpdatingAvatar])
        {
            TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:nil actions:@[
                [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"GroupInfo.SetGroupPhotoStop") action:@"stop" type:TGActionSheetActionTypeDestructive],
                [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel],
            ] actionBlock:^(id target, NSString *action)
            {
                if ([action isEqualToString:@"stop"])
                {
                    [(TGEditProfileController *)target _commitCancelAvatarUpdate];
                }
            } target:self];
            [actionSheet showInView:self.view];
        }
        else
        {
            [self setProfilePhotoPressed];
        }
    }
    else if ([action isEqualToString:@"deleteAvatar"])
    {
        [self _commitDeleteAvatar];
    }
    else if ([action isEqualToString:@"editingNameChanged"])
    {
        _doneItem.enabled = [_profileDataItem editingFirstName].length != 0;
    }
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)__unused resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/tg/loggedOut"])
    {
        TGDispatchOnMainThread(^{
            [_progressWindow dismiss:true];
            _progressWindow = nil;
        });
    }
    else if ([path isEqualToString:@"/tg/userdatachanges"] || [path isEqualToString:@"/tg/userpresencechanges"])
    {
        NSArray *users = ((SGraphObjectNode *)resource).object;
        
        for (TGUser *user in users)
        {
            if (user.uid == _uid)
            {
                TGDispatchOnMainThread(^
                {
                    [_profileDataItem setUser:user animated:true];
                    [_usernameItem setVariant:user.userName.length == 0 ? TGLocalized(@"Settings.UsernameEmpty") : [[NSString alloc] initWithFormat:@"@%@", user.userName]];
                    [_phoneNumberItem setVariant:user.phoneNumber.length == 0 ? @"" : [TGPhoneUtils formatPhone:user.phoneNumber forceInternational:true]];
                });
            }
        }
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:[[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/uploadPhoto", _uid]] || [path hasPrefix:[[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/deleteAvatar/", _uid]])
    {
        TGImageInfo *imageInfo = ((TGTimelineItem *)((SGraphObjectNode *)result).object).imageInfo;
        
        TGDispatchOnMainThread(^
        {
            if (status == ASStatusSuccess)
            {
                NSString *photoUrl = [imageInfo closestImageUrlWithSize:CGSizeMake(160, 160) resultingSize:NULL];
            
                if (photoUrl != nil)
                    [_profileDataItem copyUpdatingAvatarToCacheWithUri:photoUrl];
            
                [_profileDataItem resetUpdatingAvatar:photoUrl];
            }
            else
            {
                [_profileDataItem setUpdatingAvatar:nil hasUpdatingAvatar:false];
                
                TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Login.UnknownError") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
                [alertView show];
            }
        });
    }
}

- (void)_updateProfileImage:(UIImage *)image
{
    if (image == nil)
        return;
    
    if (MIN(image.size.width, image.size.height) < 160.0f)
        image = TGScaleImageToPixelSize(image, CGSizeMake(160, 160));
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6f);
    if (imageData == nil)
        return;
    
    [(UIView *)[_profileDataItem visibleAvatarView] setHidden:false];
    
    TGImageProcessor filter = [TGRemoteImageView imageProcessorForName:@"circle:64x64"];
    UIImage *avatarImage = filter(image);
    
    [_profileDataItem setUpdatingAvatar:avatarImage hasUpdatingAvatar:true];
    
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    
    uint8_t fileId[32];
    arc4random_buf(&fileId, 32);
    
    NSMutableString *filePath = [[NSMutableString alloc] init];
    for (int i = 0; i < 32; i++)
    {
        [filePath appendFormat:@"%02x", fileId[i]];
    }
    
    NSString *tmpImagesPath = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"upload"];
    static NSFileManager *fileManager = nil;
    if (fileManager == nil)
        fileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    [fileManager createDirectoryAtPath:tmpImagesPath withIntermediateDirectories:true attributes:nil error:&error];
    NSString *absoluteFilePath = [tmpImagesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bin", filePath]];
    [imageData writeToFile:absoluteFilePath atomically:true];
    
    [options setObject:filePath forKey:@"originalFileUrl"];
    
    [options setObject:avatarImage forKey:@"currentPhoto"];
    
    [ActionStageInstance() dispatchOnStageQueue:^
     {
         NSString *action = [[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/uploadPhoto/(%@)", _uid, filePath];
         [ActionStageInstance() requestActor:action options:options watcher:self];
         [ActionStageInstance() requestActor:action options:options watcher:TGTelegraphInstance];
     }];
}

- (void)_commitCancelAvatarUpdate
{
    [_profileDataItem setUpdatingAvatar:nil hasUpdatingAvatar:false];
    
    [ActionStageInstance() dispatchOnStageQueue:^
     {
         NSArray *deleteActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/timeline/@/deleteAvatar/@" prefix:[[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")", _uid] watcher:self];
         NSArray *uploadActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/timeline/@/uploadPhoto/@" prefix:[[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")", _uid] watcher:self];
         
         for (NSString *action in deleteActions)
         {
             [ActionStageInstance() removeAllWatchersFromPath:action];
         }
         
         for (NSString *action in uploadActions)
         {
             [ActionStageInstance() removeAllWatchersFromPath:action];
         }
     }];
}

- (void)_commitDeleteAvatar
{
    [_profileDataItem setHasUpdatingAvatar:true];
    
    static int actionId = 0;
    
    NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:_uid], @"uid", nil];
    NSString *action = [[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/deleteAvatar/(%d)", _uid, actionId++];
    [ActionStageInstance() requestActor:action options:options watcher:self];
    [ActionStageInstance() requestActor:action options:options watcher:TGTelegraphInstance];
}

- (void)_resetCollectionView {
    [super _resetCollectionView];
    
    if (iosMajorVersion() >= 7) {
        self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
}

- (void)logoutPressed
{
    __weak TGEditProfileController *weakSelf = self;
    
    [[TGInterfaceManager instance] dismissAllCalls];
    
    [[[TGAlertView alloc] initWithTitle:TGLocalized(@"Settings.LogoutConfirmationTitle") message:TGLocalized(@"Settings.LogoutConfirmationText") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
      {
          if (okButtonPressed)
          {
              __strong TGEditProfileController *strongSelf = weakSelf;
              if (strongSelf != nil)
              {
                  strongSelf.progressWindow = [[TGProgressWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                  [strongSelf.progressWindow show:true];
                  
                  static int actionId = 0;
                  [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/auth/logout/(%d)", actionId++] options:nil watcher:strongSelf];
              }
          }
      }] show];
}

@end
