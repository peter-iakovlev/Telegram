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

#import "UIDevice+PlatformInfo.h"
#import "TGImageUtils.h"
#import "TGActionSheet.h"

#import "TGRemoteImageView.h"

#import "TGUploadFileSignals.h"

#import "TGChannelIntroController.h"

#import "TGGroupManagementSignals.h"

#import "TGMediaAvatarMenuMixin.h"

#import "TGTelegramNetworking.h"

@interface TGCreateGroupController () <TGGroupInfoSelectContactControllerDelegate, ASWatcher>
{
    NSArray *_userIds;
    bool _createChannel;
    bool _createChannelGroup;
    
    TGGroupInfoCollectionItem *_groupInfoItem;
    TGButtonCollectionItem *_setGroupPhotoItem;
    
    TGCollectionMenuSection *_usersSection;
    
    TGCollectionMenuSection *_infoSection;
    TGCollectionMultilineInputItem *_aboutInputItem;
    
    bool _makeFieldFirstResponder;
    
    TGButtonCollectionItem *_addParticipantItem;
    
    SVariable *_uploadedPhotoFile;
    SVariable *_canCreatePublic;
    
    TGMediaAvatarMenuMixin *_avatarMixin;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGCreateGroupController

- (instancetype)init
{
    return [self initWithCreateChannel:false createChannelGroup:false];
}

- (instancetype)initWithCreateChannel:(bool)createChannel createChannelGroup:(bool)createChannelGroup
{
    self = [super init];
    if (self)
    {
        _createChannel = createChannel;
        _createChannelGroup = createChannelGroup;
        
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
            
            SSignal *createSignal = [TGChannelManagementSignals makeChannelWithTitle:_groupInfoItem.editingTitle about:_aboutInputItem.text group:false];
            
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
            
            SSignal *createAndCheckUsernames = [createAndUpdatePhoto mapToSignal:^SSignal *(NSDictionary *dict) {
                TGConversation *conversation = dict[@"conversation"];
                return [[[TGGroupManagementSignals conversationsToBeRemovedToAssignPublicUsernames:conversation.conversationId accessHash:conversation.accessHash] catch:^SSignal *(__unused id error) {
                    return [SSignal single:@[]];
                }] map:^id(NSArray *conversationsToDeleteForPublicUsernames) {
                    NSMutableDictionary *updatedDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
                    if (conversationsToDeleteForPublicUsernames != nil) {
                        updatedDict[@"conversationsToDeleteForPublicUsernames"] = conversationsToDeleteForPublicUsernames;
                    }
                    return updatedDict;
                }];
            }];
            
            [[[createAndCheckUsernames deliverOn:[SQueue mainQueue]] onDispose:^{
                TGDispatchOnMainThread(^{
                    [progressWindow dismiss:true];
                });
            }] startWithNext:^(NSDictionary *dict) {
                TGConversation *conversation = dict[@"conversation"];
                NSString *link = dict[@"link"];
                
                __strong TGCreateGroupController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    TGSetupChannelAfterCreationController *setupController = [[TGSetupChannelAfterCreationController alloc] initWithConversation:conversation exportedLink:link modal:false conversationsToDeleteForPublicUsernames:dict[@"conversationsToDeleteForPublicUsernames"] checkConversationsToDeleteForPublicUsernames:false];
                    
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
        } else if ((_userIds.count != 0 || _createChannelGroup) && (_groupInfoItem.editingTitle.length != 0))
        {
            if (_createChannelGroup) {
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                [progressWindow show:true];
                __weak TGCreateGroupController *weakSelf = self;
                
                SSignal *createSignal = [TGChannelManagementSignals makeChannelWithTitle:_groupInfoItem.editingTitle about:_aboutInputItem.text group:true];
                
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
                        TGSetupChannelAfterCreationController *setupController = [[TGSetupChannelAfterCreationController alloc] initWithConversation:conversation exportedLink:link modal:false conversationsToDeleteForPublicUsernames:@[] checkConversationsToDeleteForPublicUsernames:false];
                        
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
            } else {
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
                } error:^(id error) {
                    NSString *errorType = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
                    NSString *errorText = TGLocalized(@"Profile.CreateEncryptedChatError");
                    if ([errorType isEqualToString:@"USERS_TOO_FEW"] || [errorType isEqualToString:@"USER_PRIVACY_RESTRICTED"]) {
                        errorText = TGLocalized(@"Privacy.GroupsAndChannels.InviteToChannelMultipleError");
                    }
                    
                    [[[TGAlertView alloc] initWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                } completed:^{
                }];
            }
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

- (void)setGroupPhotoPressed
{
    __weak TGCreateGroupController *weakSelf = self;
    _avatarMixin = [[TGMediaAvatarMenuMixin alloc] initWithParentController:self hasDeleteButton:([_groupInfoItem staticAvatar] != nil)];
    _avatarMixin.didFinishWithImage = ^(UIImage *image)
    {
        __strong TGCreateGroupController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _updateGroupProfileImage:image];
        strongSelf->_avatarMixin = nil;
    };
    _avatarMixin.didFinishWithDelete = ^
    {
        __strong TGCreateGroupController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _commitDeleteAvatar];
        strongSelf->_avatarMixin = nil;
    };
    _avatarMixin.didDismiss = ^
    {
        __strong TGCreateGroupController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_avatarMixin = nil;
    };
    [_avatarMixin present];
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
    [_uploadedPhotoFile set:[TGUploadFileSignals uploadedFileWithData:imageData mediaTypeTag:TGNetworkMediaTypeTagImage]];
}

- (void)_commitDeleteAvatar
{
    [_groupInfoItem setStaticAvatar:nil];
    [_uploadedPhotoFile set:[SSignal single:nil]];
}

@end
