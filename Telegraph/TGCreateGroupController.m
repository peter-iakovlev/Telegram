/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCreateGroupController.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGDatabase.h"

#import "TGInterfaceManager.h"
#import "TGAppDelegate.h"

#import "TGGroupInfoCollectionItem.h"
#import "TGGroupInfoUserCollectionItem.h"
#import "TGHeaderCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGProgressWindow.h"

#import "TGAlertView.h"

#import "TGChannelManagementSignals.h"
#import "TGButtonCollectionItem.h"
#import "TGVariantCollectionItem.h"

#import "TGGroupInfoSelectContactController.h"
#import "TGNavigationBar.h"
#import "TGNavigationController.h"

#import "TGChannelAboutSetupController.h"
#import "TGChannelLinkSetupController.h"

#import "TGCollectionMultilineInputItem.h"

#import "TGSelectContactController.h"

#import "TGSetupChannelAfterCreationController.h"

#import "TGLegacyCameraController.h"
#import "TGImagePickerController.h"

#import "TGOverlayFormsheetWindow.h"
#import "TGMediaFoldersController.h"
#import "TGModernMediaPickerController.h"
#import "TGWebSearchController.h"
#import "TGCameraController.h"
#import "TGAttachmentSheetRecentCameraView.h"
#import "TGAttachmentSheetView.h"

#import "TGImageUtils.h"
#import "TGActionSheet.h"
#import "TGAccessChecker.h"
#import "TGCameraController.h"
#import "TGCameraPreviewView.h"
#import "TGAttachmentSheetWindow.h"

#import "TGRemoteImageView.h"

#import "TGUploadFileSignals.h"

#import "TGChannelIntroController.h"

#import "TGGroupManagementSignals.h"

@interface TGCreateGroupController () <TGGroupInfoSelectContactControllerDelegate, TGLegacyCameraControllerDelegate, ASWatcher>
{
    NSArray *_userIds;
    bool _createChannel;
    
    TGGroupInfoCollectionItem *_groupInfoItem;
    TGButtonCollectionItem *_setGroupPhotoItem;
    
    TGCollectionMenuSection *_usersSection;
    
    TGCollectionMenuSection *_infoSection;
    TGCollectionMultilineInputItem *_aboutInputItem;
    
    bool _makeFieldFirstResponder;
    
    TGButtonCollectionItem *_addParticipantItem;
    TGAttachmentSheetWindow *_attachmentSheetWindow;
    
    SVariable *_uploadedPhotoFile;
    SVariable *_canCreatePublic;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGCreateGroupController

- (instancetype)init
{
    return [self initWithCreateChannel:false];
}

- (instancetype)initWithCreateChannel:(bool)createChannel
{
    self = [super init];
    if (self)
    {
        _createChannel = createChannel;
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        NSString *titleString = TGLocalized(@"Compose.NewGroup");
        if (_createChannel) {
            titleString = TGLocalized(@"Compose.NewChannel");
        }
        
        [self setTitleText:titleString];
        if (_createChannel) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Close") style:UIBarButtonItemStylePlain target:self action:@selector(closePressed)]];
            }
            
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Next") style:UIBarButtonItemStyleDone target:self action:@selector(createPressed)]];
        } else {
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Create") style:UIBarButtonItemStyleDone target:self action:@selector(createPressed)]];
        }
        self.navigationItem.rightBarButtonItem.enabled = false;
        
        _groupInfoItem = [[TGGroupInfoCollectionItem alloc] init];
        _groupInfoItem.isChannel = _createChannel;
        _groupInfoItem.interfaceHandle = _actionHandle;
        [_groupInfoItem setConversation:nil];
        [_groupInfoItem setEditing:true];
        
        _setGroupPhotoItem = [[TGButtonCollectionItem alloc] initWithTitle:_createChannel ? TGLocalized(@"Channel.UpdatePhotoItem") : TGLocalized(@"GroupInfo.SetGroupPhoto") action:@selector(setGroupPhotoPressed)];
        _setGroupPhotoItem.titleColor = TGAccentColor();
        _setGroupPhotoItem.deselectAutomatically = true;
        
        TGCollectionMenuSection *groupInfoSection = [[TGCollectionMenuSection alloc] initWithItems:@[_groupInfoItem, _setGroupPhotoItem]];
        [self.menuSections addSection:groupInfoSection];

        _usersSection = [[TGCollectionMenuSection alloc] init];
        
        if (_createChannel) {
            _canCreatePublic = [[SVariable alloc] init];
            [_canCreatePublic set:[TGChannelManagementSignals canMakePublicChannels]];
            
            _aboutInputItem = [[TGCollectionMultilineInputItem alloc] init];
            _aboutInputItem.maxLength = 200;
            _aboutInputItem.placeholder = TGLocalized(@"Channel.About.Placeholder");
            __weak TGCreateGroupController *weakSelf = self;
            _aboutInputItem.heightChanged = ^ {
                __strong TGCreateGroupController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf.collectionLayout invalidateLayout];
                    [strongSelf.collectionView layoutSubviews];
                }
            };
            
            TGCommentCollectionItem *commentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Channel.About.Help")];
            commentItem.topInset = 1.0f;
            
            _infoSection = [[TGCollectionMenuSection alloc] initWithItems:@[_aboutInputItem, commentItem]];
            [self.menuSections addSection:_infoSection];
        } else {
            [self.menuSections addSection:_usersSection];
        }
        
        _makeFieldFirstResponder = true;
        
        _uploadedPhotoFile = [[SVariable alloc] init];
        [_uploadedPhotoFile set:[SSignal single:nil]];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)closePressed {
    [TGAppDelegateInstance.rootController clearContentControllers];
}

- (void)_resetCollectionView {
    [super _resetCollectionView];
    
    if (iosMajorVersion() >= 7) {
        self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
}

- (void)createPressed
{
    if (_groupInfoItem.editingTitle.length != 0) {
        if (_createChannel) {
            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [progressWindow show:true];
            __weak TGCreateGroupController *weakSelf = self;
            
            SSignal *createSignal = [TGChannelManagementSignals makeChannelWithTitle:_groupInfoItem.editingTitle about:_aboutInputItem.text userIds:@[]];
            
            SSignal *createAndExportLink = [createSignal mapToSignal:^SSignal *(TGConversation *conversation) {
                return [[TGChannelManagementSignals exportChannelInvitationLink:conversation.conversationId accessHash:conversation.accessHash] map:^id(NSString *link) {
                    return @{@"conversation": conversation, @"link": link};
                }];
            }];
            
            SSignal *uploadedPhotoFileSignal = [[_uploadedPhotoFile signal] take:1];
            
            SSignal *createAndUpdatePhoto = [createAndExportLink mapToSignal:^SSignal *(NSDictionary *dict) {
                TGConversation *conversation = dict[@"conversation"];
                
                return [uploadedPhotoFileSignal mapToSignal:^SSignal *(id inputFile) {
                    if (inputFile == nil) {
                        return [SSignal single:dict];
                    } else {
                        return [[[TGChannelManagementSignals updateChannelPhoto:conversation.conversationId accessHash:conversation.accessHash uploadedFile:[SSignal single:inputFile]] mapToSignal:^SSignal *(__unused id next) {
                            return [SSignal complete];
                        }] then:[SSignal single:dict]];
                    }
                }];
            }];
            
            [[[createAndUpdatePhoto deliverOn:[SQueue mainQueue]] onDispose:^{
                TGDispatchOnMainThread(^{
                    [progressWindow dismiss:true];
                });
            }] startWithNext:^(NSDictionary *dict) {
                TGConversation *conversation = dict[@"conversation"];
                NSString *link = dict[@"link"];
                
                __strong TGCreateGroupController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    TGSetupChannelAfterCreationController *setupController = [[TGSetupChannelAfterCreationController alloc] initWithConversation:conversation exportedLink:link];
                    
                    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:strongSelf.navigationController.viewControllers];
                    if (viewControllers.count != 1) {
                        [viewControllers removeObjectsInRange:NSMakeRange(1, viewControllers.count - 1)];
                    }
                    [viewControllers addObject:setupController];
                    
                    [strongSelf.navigationController setViewControllers:viewControllers animated:true];
                }
            } error:^(__unused id error) {
            } completed:^{
            }];
        } else if (_userIds.count != 0 && (_groupInfoItem.editingTitle.length != 0))
        {
            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [progressWindow show:true];
            __weak TGCreateGroupController *weakSelf = self;
            
            NSMutableArray *users = [[NSMutableArray alloc] init];
            for (NSNumber *nUserId in _userIds) {
                TGUser *user = [TGDatabaseInstance() loadUser:[nUserId intValue]];
                if (user != nil) {
                    [users addObject:user];
                }
            }
            
            SSignal *createSignal = [TGGroupManagementSignals makeGroupWithTitle:_groupInfoItem.editingTitle users:users];
            
            SSignal *uploadedPhotoFileSignal = [[_uploadedPhotoFile signal] take:1];
            
            SSignal *createAndUpdatePhoto = [createSignal mapToSignal:^SSignal *(TGConversation *conversation) {
                return [uploadedPhotoFileSignal mapToSignal:^SSignal *(id inputFile) {
                    if (inputFile == nil) {
                        return [SSignal single:conversation];
                    } else {
                        return [[[TGGroupManagementSignals updateGroupPhoto:conversation.conversationId uploadedFile:[SSignal single:inputFile]] mapToSignal:^SSignal *(__unused id next) {
                            return [SSignal complete];
                        }] then:[SSignal single:conversation]];
                    }
                }];
            }];
            
            [[[createAndUpdatePhoto deliverOn:[SQueue mainQueue]] onDispose:^{
                TGDispatchOnMainThread(^{
                    [progressWindow dismiss:true];
                });
            }] startWithNext:^(TGConversation *conversation) {
                __strong TGCreateGroupController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [[TGInterfaceManager instance] navigateToConversationWithId:conversation.conversationId conversation:nil];
                }
            } error:^(__unused id error) {
            } completed:^{
            }];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    TGViewController *introController = nil;
    for (UIViewController *controller in controllers)
    {
        if ([controller isKindOfClass:[TGChannelIntroController class]])
        {
            introController = (TGChannelIntroController *)controller;
            break;
        }
    }
    if (introController != nil)
    {
        [controllers removeObject:introController];
        self.navigationController.viewControllers = controllers;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (_makeFieldFirstResponder)
    {
        _makeFieldFirstResponder = false;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_groupInfoItem makeNameFieldFirstResponder];
        });
    }
}

- (void)setUserIds:(NSArray *)userIds
{
    _userIds = userIds;
    
    NSMutableArray *users = [[NSMutableArray alloc] init];
    for (NSNumber *nUid in _userIds)
    {
        TGUser *user = [TGDatabaseInstance() loadUser:[nUid int32Value]];
        if (user != nil)
            [users addObject:user];
    }
    
    NSUInteger usersSectionIndex = [self indexForSection:_usersSection];
    if (usersSectionIndex != NSNotFound)
    {
        for (int i = (int)_usersSection.items.count - 1; i >= 0; i--)
        {
            [self.menuSections deleteItemFromSection:usersSectionIndex atIndex:0];
        }
    }
    
    for (TGUser *user in users)
    {
        TGGroupInfoUserCollectionItem *userItem = [[TGGroupInfoUserCollectionItem alloc] init];
        [userItem setUser:user];
        userItem.selectable = false;
        [userItem setCanEdit:false];
        [self.menuSections addItemToSection:usersSectionIndex item:userItem];
    }
    
    [self.collectionView reloadData];
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"editedTitleChanged"])
    {
        self.navigationItem.rightBarButtonItem.enabled = [_groupInfoItem.editingTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length != 0;
        TGConversation *conversation = [[TGConversation alloc] init];
        conversation.chatTitle = _groupInfoItem.editingTitle;
        [_groupInfoItem setConversation:conversation];
    } else if ([action isEqualToString:@"openUser"]) {
        [[TGInterfaceManager instance] navigateToProfileOfUser:[options[@"uid"] intValue]];
    } else if ([action isEqualToString:@"openAvatar"]) {
        [self setGroupPhotoPressed];
    }
}

- (void)setGroupPhotoPressed {
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.TakePhoto") action:@"camera"]];
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.ChoosePhoto") action:@"choosePhoto"]];
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.SearchWebImages") action:@"searchWeb"]];
    
    if ([_groupInfoItem staticAvatar] != nil) {
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"GroupInfo.SetGroupPhotoDelete") action:@"delete" type:TGActionSheetActionTypeDestructive]];
    }
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGCreateGroupController *controller, NSString *action)
    {
        if ([action isEqualToString:@"camera"])
            [controller _displayCameraWithView:nil];
        else if ([action isEqualToString:@"choosePhoto"])
            [controller _displayImagePicker:false];
        else if ([action isEqualToString:@"searchWeb"])
            [controller _displayImagePicker:true];
        else if ([action isEqualToString:@"delete"])
            [controller _commitDeleteAvatar];
    } target:self] showInView:self.view];
}

- (void)_displayCameraWithView:(TGAttachmentSheetRecentCameraView *)cameraView
{
    if (![TGAccessChecker checkCameraAuthorizationStatusWithAlertDismissComlpetion:nil])
        return;
    
    TGCameraController *controller = nil;
    CGSize screenSize = TGScreenSize();
    
    if (cameraView.previewView != nil)
        controller = [[TGCameraController alloc] initWithCamera:cameraView.previewView.camera previewView:cameraView.previewView intent:TGCameraControllerAvatarIntent];
    else
        controller = [[TGCameraController alloc] initWithIntent:TGCameraControllerAvatarIntent];
    
    controller.shouldStoreCapturedAssets = true;
    
    TGCameraControllerWindow *controllerWindow = [[TGCameraControllerWindow alloc] initWithParentController:self contentController:controller];
    if (_attachmentSheetWindow != nil)
        controllerWindow.windowLevel = _attachmentSheetWindow.windowLevel + 0.0001f;
    controllerWindow.hidden = false;
    controllerWindow.clipsToBounds = true;
    controllerWindow.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    
    bool standalone = true;
    CGRect startFrame = CGRectMake(0, screenSize.height, screenSize.width, screenSize.height);
    if (cameraView != nil)
    {
        standalone = false;
        startFrame = [controller.view convertRect:cameraView.previewView.frame fromView:cameraView];
    }
    
    [cameraView detachPreviewView];
    [controller beginTransitionInFromRect:startFrame];
    
    __weak TGCreateGroupController *weakSelf = self;
    __weak TGCameraController *weakCameraController = controller;
    __weak TGAttachmentSheetRecentCameraView *weakCameraView = cameraView;
    
    controller.beginTransitionOut = ^CGRect
    {
        __strong TGCameraController *strongCameraController = weakCameraController;
        if (strongCameraController == nil)
            return CGRectZero;
        
        if (!standalone)
        {
            __strong TGAttachmentSheetRecentCameraView *strongCameraView = weakCameraView;
            if (strongCameraView != nil)
                return [strongCameraController.view convertRect:strongCameraView.frame fromView:strongCameraView.superview];
        }
        
        return CGRectZero;
    };
    
    controller.finishedTransitionOut = ^
    {
        __strong TGAttachmentSheetRecentCameraView *strongCameraView = weakCameraView;
        if (strongCameraView == nil)
            return;
        
        [strongCameraView attachPreviewViewAnimated:true];
    };
    
    controller.finishedWithPhoto = ^(UIImage *resultImage, __unused NSString *caption)
    {
        __strong TGCreateGroupController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _updateGroupProfileImage:resultImage];
        [strongSelf->_attachmentSheetWindow dismissAnimated:false completion:nil];
    };
}

- (void)_displayLegacyCamera
{
    TGLegacyCameraController *legacyCameraController = [[TGLegacyCameraController alloc] init];
    legacyCameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    legacyCameraController.avatarMode = true;
    
    legacyCameraController.completionDelegate = self;
    
    [self presentViewController:legacyCameraController animated:true completion:nil];
}

- (void)_displayImagePicker:(bool)openWebSearch
{
    __weak TGCreateGroupController *weakSelf = self;
    
    TGNavigationController *navigationController = nil;
    
    if (openWebSearch)
    {
        TGWebSearchController *controller = [[TGWebSearchController alloc] initForAvatarSelection:true];
        __weak TGWebSearchController *weakController = controller;
        controller.avatarCreated = ^(UIImage *image)
        {
            __strong TGCreateGroupController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf _updateGroupProfileImage:image];
            
            __strong TGWebSearchController *strongController = weakController;
            if (strongController != nil && strongController.dismiss != nil)
                strongController.dismiss();
        };
        
        navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            void (^dismiss)(void) = ^
            {
                __strong TGCreateGroupController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                [strongSelf dismissViewControllerAnimated:true completion:nil];
            };
            
            [self presentViewController:navigationController animated:true completion:nil];
            
            controller.dismiss = dismiss;
        }
        else
        {
            navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            
            TGOverlayFormsheetWindow *formSheetWindow = [[TGOverlayFormsheetWindow alloc] initWithParentController:self contentController:navigationController];
            [formSheetWindow showAnimated:true];
            
            __weak TGOverlayFormsheetWindow *weakFormSheetWindow = formSheetWindow;
            void (^dismiss)(void) = ^
            {
                __strong TGOverlayFormsheetWindow *strongFormSheetWindow = weakFormSheetWindow;
                if (strongFormSheetWindow == nil)
                    return;
                
                [strongFormSheetWindow dismissAnimated:true];
            };
            
            controller.dismiss = dismiss;
        }
    }
    else
    {
        TGMediaFoldersController *mediaFoldersController = [[TGMediaFoldersController alloc] initWithIntent:TGModernMediaPickerControllerSetProfilePhotoIntent];
        TGModernMediaPickerController *mediaPickerController = [[TGModernMediaPickerController alloc] initWithAssetsGroup:nil intent:TGModernMediaPickerControllerSetProfilePhotoIntent];
        
        navigationController = [TGNavigationController navigationControllerWithControllers:@[ mediaFoldersController, mediaPickerController ]];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            void (^dismiss)(void) = ^
            {
                __strong TGCreateGroupController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                [strongSelf dismissViewControllerAnimated:true completion:nil];
            };
            
            mediaFoldersController.dismiss = dismiss;
            mediaPickerController.dismiss = dismiss;
            
            [self presentViewController:navigationController animated:true completion:nil];
        }
        else
        {
            navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            
            TGOverlayFormsheetWindow *formSheetWindow = [[TGOverlayFormsheetWindow alloc] initWithParentController:self contentController:navigationController];
            [formSheetWindow showAnimated:true];
            
            __weak TGOverlayFormsheetWindow *weakFormSheetWindow = formSheetWindow;
            void (^dismiss)(void) = ^
            {
                __strong TGOverlayFormsheetWindow *strongFormSheetWindow = weakFormSheetWindow;
                if (strongFormSheetWindow == nil)
                    return;
                
                [strongFormSheetWindow dismissAnimated:true];
            };
            
            mediaFoldersController.dismiss = dismiss;
            mediaPickerController.dismiss = dismiss;
        }
        
        __weak TGMediaFoldersController *weakMediaFoldersController = mediaFoldersController;
        void(^avatarCreated)(UIImage *) = ^(UIImage *image)
        {
            __strong TGCreateGroupController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf _updateGroupProfileImage:image];
            
            __strong TGMediaFoldersController *strongMediaFoldersController = weakMediaFoldersController;
            if (strongMediaFoldersController != nil && strongMediaFoldersController.dismiss != nil)
                strongMediaFoldersController.dismiss();
        };
        
        mediaFoldersController.avatarCreated = avatarCreated;
        mediaPickerController.avatarCreated = avatarCreated;
    }
}

- (void)imagePickerController:(TGImagePickerController *)__unused imagePicker didFinishPickingWithAssets:(NSArray *)assets
{
    UIImage *image = nil;
    
    if (assets.count != 0)
    {
        if ([assets[0] isKindOfClass:[UIImage class]])
            image = assets[0];
    }
    
    [self _updateGroupProfileImage:image];
    
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)_updateGroupProfileImage:(UIImage *)image
{
    if (image == nil)
        return;
    
    if (MIN(image.size.width, image.size.height) < 160.0f)
        image = TGScaleImageToPixelSize(image, CGSizeMake(160, 160));
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6f);
    if (imageData == nil)
        return;
    
    TGImageProcessor filter = [TGRemoteImageView imageProcessorForName:@"circle:64x64"];
    UIImage *avatarImage = filter(image);
    
    [_groupInfoItem setStaticAvatar:avatarImage];
    [_uploadedPhotoFile set:[TGUploadFileSignals uploadedFileWithData:imageData]];
}

- (void)_commitDeleteAvatar
{
    [_groupInfoItem setStaticAvatar:nil];
    [_uploadedPhotoFile set:[SSignal single:nil]];
}

@end
