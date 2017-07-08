#import "TGPasscodeSettingsController.h"

#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGVariantCollectionItem.h"

#import "TGDatabase.h"
#import "TGImageUtils.h"
#import "TGAppDelegate.h"

#import <LocalAuthentication/LocalAuthentication.h>

#import "TGNavigationController.h"
#import "TGPasscodeEntryController.h"

#import "TGProgressWindow.h"
#import "TGActionSheet.h"

#import "TGTelegramNetworking.h"

@interface TGPasscodeSettingsController ()
{
    TGCollectionMenuSection *_buttonsSection;
    TGButtonCollectionItem *_turnPasscodeOnItem;
    TGButtonCollectionItem *_turnPasscodeOffItem;
    TGButtonCollectionItem *_changePasscodeItem;
    
    TGCollectionMenuSection *_infoSection;
    TGCommentCollectionItem *_infoItem;
    
    TGCollectionMenuSection *_timeoutSection;
    TGVariantCollectionItem *_timeoutIntervalItem;
    
    TGCollectionMenuSection *_optionsSection;
    TGSwitchCollectionItem *_touchIdItem;
    TGSwitchCollectionItem *_simplePasscodeItem;
    TGCommentCollectionItem *_optionsInfoItem;
    
    TGCollectionMenuSection *_encryptDataSection;
    TGSwitchCollectionItem *_encryptDataItem;
    TGCommentCollectionItem *_encryptDataInfoItem;
}

@end

@implementation TGPasscodeSettingsController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.title = TGLocalized(@"PasscodeSettings.Title");
        
        __weak TGPasscodeSettingsController *weakSelf = self;
        
        _buttonsSection = [[TGCollectionMenuSection alloc] init];
        _buttonsSection.insets = UIEdgeInsetsMake(37.0f, 0.0f, 0.0f, 0.0f);
        
        _turnPasscodeOnItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"PasscodeSettings.TurnPasscodeOn") action:@selector(turnPasscodeOnPressed)];
        _turnPasscodeOnItem.deselectAutomatically = true;
        _turnPasscodeOnItem.titleColor = TGAccentColor();
        _turnPasscodeOnItem.alignment = NSTextAlignmentLeft;
        
        _turnPasscodeOffItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"PasscodeSettings.TurnPasscodeOff") action:@selector(turnPasscodeOffPressed)];
        _turnPasscodeOffItem.deselectAutomatically = true;
        _turnPasscodeOffItem.titleColor = TGAccentColor();
        _turnPasscodeOffItem.alignment = NSTextAlignmentLeft;

        _changePasscodeItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"PasscodeSettings.ChangePasscode") action:@selector(changePasscodePressed)];
        _changePasscodeItem.deselectAutomatically = true;
        _changePasscodeItem.titleColor = TGAccentColor();
        _changePasscodeItem.alignment = NSTextAlignmentLeft;
        
        _timeoutIntervalItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"PasscodeSettings.AutoLock") variant:@"" action:@selector(autoLockPressed)];
        _timeoutIntervalItem.deselectAutomatically = true;
        _timeoutSection = [[TGCollectionMenuSection alloc] initWithItems:@[_timeoutIntervalItem]];
        _timeoutSection.insets = UIEdgeInsetsMake(4.0f, 0.0f, 0.0f, 0.0f);
        
        _infoSection = [[TGCollectionMenuSection alloc] init];
        _infoSection.insets = UIEdgeInsetsMake(4.0f, 0.0f, 0.0f, 0.0f);
        
        _infoItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"PasscodeSettings.Help")];
        
        _optionsSection = [[TGCollectionMenuSection alloc] init];
        _optionsSection.insets = UIEdgeInsetsMake(26.0f, 0.0f, 44.0f, 0.0f);
        
        _touchIdItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"PasscodeSettings.UnlockWithTouchId") isOn:false];
        _touchIdItem.toggled = ^(bool value, __unused TGSwitchCollectionItem *item)
        {
            __strong TGPasscodeSettingsController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf touchIdToggled:value];
        };
        _simplePasscodeItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"PasscodeSettings.SimplePasscode") isOn:false];
        _simplePasscodeItem.toggled = ^(bool value, __unused TGSwitchCollectionItem *item)
        {
            __strong TGPasscodeSettingsController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf simplePasscodeToggled:value];
        };
        _optionsInfoItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"PasscodeSettings.SimplePasscodeHelp")];
        _optionsInfoItem.topInset = 3.0f + TGRetinaPixel;
        
        _encryptDataItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"PasscodeSettings.EncryptData") isOn:false];
        _encryptDataItem.toggled = ^(bool value, __unused TGSwitchCollectionItem *item)
        {
            __strong TGPasscodeSettingsController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf encryptDataToggled:value];
        };
        
        _encryptDataInfoItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"PasscodeSettings.EncryptDataHelp")];
        _encryptDataInfoItem.topInset = 3.0f + TGRetinaPixel;
        
        _encryptDataSection = [[TGCollectionMenuSection alloc] initWithItems:@[_encryptDataItem, _encryptDataInfoItem]];
        _encryptDataSection.insets = UIEdgeInsetsMake(10.0f, 0.0f, 44.0f, 0.0f);
        
        [self _updateSections];
    }
    return self;
}

+ (bool)supportsTouchId
{
    if (iosMajorVersion() >= 8) {
        __autoreleasing NSError *error = nil;
        if ([[[LAContext alloc] init] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
            return true;
        }
        if (error.code != kLAErrorTouchIDNotAvailable) {
            return true;
        }
    }
    
    return false;
}

- (bool)hasPasscode
{
    return [TGDatabaseInstance() isPasswordSet:NULL];
}

- (bool)passcodeIsSimple
{
    bool isStrong = false;
    if ([TGDatabaseInstance() isPasswordSet:&isStrong])
        return !isStrong;
    return true;
}

+ (bool)enableTouchId
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"Passcode_useTouchId"] boolValue];
}

- (bool)enableTouchId
{
    return [TGPasscodeSettingsController enableTouchId];
}

- (void)setEnableTouchId:(bool)enableTouchId
{
    [[NSUserDefaults standardUserDefaults] setObject:@(enableTouchId) forKey:@"Passcode_useTouchId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    TGDispatchOnMainThread(^
    {
        [[TGTelegramNetworking instance] exportCredentialsForExtensions];
    });
}

- (void)_updateSections
{
    bool hasPasscode = [self hasPasscode];
    bool passcodeIsSimple = false;
    if (hasPasscode)
        passcodeIsSimple = [self passcodeIsSimple];
    
    _simplePasscodeItem.isOn = [self passcodeIsSimple];
    _touchIdItem.isOn = [self enableTouchId];
    _encryptDataItem.isOn = [TGDatabaseInstance() isEncryptionEnabled];
    
    int32_t timeoutValue = [TGAppDelegateInstance automaticLockTimeout];
    if (timeoutValue <= 0)
        _timeoutIntervalItem.variant = TGLocalized(@"PasscodeSettings.AutoLock.Disabled");
#ifdef DEBUG
    else if (timeoutValue == 5)
        _timeoutIntervalItem.variant = @"Debug_5seconds";
#endif
    else if (timeoutValue == 1 * 60)
        _timeoutIntervalItem.variant = TGLocalized(@"PasscodeSettings.AutoLock.IfAwayFor_1minute");
    else if (timeoutValue == 5 * 60)
        _timeoutIntervalItem.variant = TGLocalized(@"PasscodeSettings.AutoLock.IfAwayFor_5minutes");
    else if (timeoutValue == 1 * 60 * 60)
        _timeoutIntervalItem.variant = TGLocalized(@"PasscodeSettings.AutoLock.IfAwayFor_1hour");
    else if (timeoutValue == 5 * 60 * 60)
        _timeoutIntervalItem.variant = TGLocalized(@"PasscodeSettings.AutoLock.IfAwayFor_5hours");
    
    NSUInteger buttonsSectionIndex = [self indexForSection:_buttonsSection];
    if (buttonsSectionIndex != NSNotFound)
    {
        while (_buttonsSection.items.count != 0)
        {
            [self.menuSections deleteItemFromSection:buttonsSectionIndex atIndex:0];
        }
    }
    
    NSUInteger infoSectionIndex = [self indexForSection:_infoSection];
    if (infoSectionIndex != NSNotFound)
    {
        while (_infoSection.items.count != 0)
        {
            [self.menuSections deleteItemFromSection:infoSectionIndex atIndex:0];
        }
    }
    
    NSUInteger optionsSectionIndex = [self indexForSection:_optionsSection];
    if (optionsSectionIndex != NSNotFound)
    {
        while (_optionsSection.items.count != 0)
        {
            [self.menuSections deleteItemFromSection:optionsSectionIndex atIndex:0];
        }
    }
    
    while (self.menuSections.sections.count != 0)
    {
        [self.menuSections deleteSection:0];
    }
    
    [self.menuSections addSection:_buttonsSection];
    buttonsSectionIndex = [self indexForSection:_buttonsSection];
    if (hasPasscode)
    {
        [self.menuSections addItemToSection:buttonsSectionIndex item:_turnPasscodeOffItem];
        [self.menuSections addItemToSection:buttonsSectionIndex item:_changePasscodeItem];
    }
    else
    {
        [self.menuSections addItemToSection:buttonsSectionIndex item:_turnPasscodeOnItem];
    }
    
    [self.menuSections addSection:_infoSection];
    infoSectionIndex = [self indexForSection:_infoSection];
    [self.menuSections addItemToSection:infoSectionIndex item:_infoItem];

    if (hasPasscode)
    {
        [self.menuSections addSection:_optionsSection];
        optionsSectionIndex = [self indexForSection:_optionsSection];
        
        [self.menuSections addItemToSection:optionsSectionIndex item:_timeoutIntervalItem];
        if ([TGPasscodeSettingsController supportsTouchId])
            [self.menuSections addItemToSection:optionsSectionIndex item:_touchIdItem];
        [self.menuSections addItemToSection:optionsSectionIndex item:_simplePasscodeItem];
        [self.menuSections addItemToSection:optionsSectionIndex item:_optionsInfoItem];
        
        if (!passcodeIsSimple)
            [self.menuSections addSection:_encryptDataSection];
    }
    
    [self.collectionView reloadData];
}

- (void)turnPasscodeOnPressed
{
    __weak TGPasscodeSettingsController *weakSelf = self;
    TGPasscodeEntryController *controller = [[TGPasscodeEntryController alloc] initWithStyle:TGPasscodeEntryControllerStyleDefault mode:TGPasscodeEntryControllerModeSetupSimple cancelEnabled:true allowTouchId:false completion:^(NSString *password)
    {
        __strong TGPasscodeSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (password != nil)
            {
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                [progressWindow show:true];
                [TGDatabaseInstance() setPassword:password isStrong:false completion:^
                {
                    TGDispatchOnMainThread(^
                    {
                        [[TGTelegramNetworking instance] exportCredentialsForExtensions];
                        
                        __strong TGPasscodeSettingsController *strongSelf = weakSelf;
                        [strongSelf _updateSections];
                        [strongSelf dismissViewControllerAnimated:true completion:nil];
                        [progressWindow dismissWithSuccess];
                        
                        [TGAppDelegateInstance setupShortcutItems];
                    });
                }];
            }
            else
                [strongSelf dismissViewControllerAnimated:true completion:nil];
        }
    }];
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        //navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        //navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    else
        navigationController.restrictLandscape = true;
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)turnPasscodeOffPressed
{
    __weak TGPasscodeSettingsController *weakSelf = self;
    TGPasscodeEntryController *controller = [[TGPasscodeEntryController alloc] initWithStyle:TGPasscodeEntryControllerStyleDefault mode:[self passcodeIsSimple] ? TGPasscodeEntryControllerModeVerifySimple : TGPasscodeEntryControllerModeVerifyComplex cancelEnabled:true  allowTouchId:false completion:^(NSString *password)
    {
        __strong TGPasscodeSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (password != nil)
            {
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                [progressWindow show:true];
                [TGDatabaseInstance() setPassword:@"" isStrong:false completion:^
                {
                    TGDispatchOnMainThread(^
                    {
                        [[TGTelegramNetworking instance] exportCredentialsForExtensions];
                        [TGAppDelegateInstance resetRemoteDeviceLocked];
                        
                        __strong TGPasscodeSettingsController *strongSelf = weakSelf;
                        [strongSelf _updateSections];
                        [strongSelf dismissViewControllerAnimated:true completion:nil];
                        [progressWindow dismissWithSuccess];
                        
                        [TGAppDelegateInstance setIsManuallyLocked:false];
                        
                        [TGAppDelegateInstance setupShortcutItems];
                    });
                }];
            }
            else
                [strongSelf dismissViewControllerAnimated:true completion:nil];
        }
    }];
    
    controller.checkCurrentPasscode = ^bool (NSString *passcode)
    {
        return [TGDatabaseInstance() verifyPassword:passcode];
    };
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        //navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        //navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    else
        navigationController.restrictLandscape = true;
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)changePasscodePressed
{
    __weak TGPasscodeSettingsController *weakSelf = self;
    TGPasscodeEntryController *controller = [[TGPasscodeEntryController alloc] initWithStyle:TGPasscodeEntryControllerStyleDefault mode:[self passcodeIsSimple] ? TGPasscodeEntryControllerModeChangeSimpleToSimple : TGPasscodeEntryControllerModeChangeComplexToComplex cancelEnabled:true allowTouchId:false completion:^(NSString *password)
    {
        __strong TGPasscodeSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (password != nil)
            {
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                [progressWindow show:true];
                [TGDatabaseInstance() setPassword:password isStrong:![strongSelf passcodeIsSimple] completion:^
                {
                    TGDispatchOnMainThread(^
                    {
                        [[TGTelegramNetworking instance] exportCredentialsForExtensions];
                        
                        __strong TGPasscodeSettingsController *strongSelf = weakSelf;
                        [strongSelf _updateSections];
                        [strongSelf dismissViewControllerAnimated:true completion:nil];
                        [progressWindow dismissWithSuccess];
                    });
                }];
            }
            else
            {
                TGDispatchOnMainThread(^
                {
                    [strongSelf dismissViewControllerAnimated:true completion:nil];
                });
            }
        }
    }];
    
    controller.checkCurrentPasscode = ^bool (NSString *passcode)
    {
        return [TGDatabaseInstance() verifyPassword:passcode];
    };
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        //navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        //navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    else
        navigationController.restrictLandscape = true;
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)autoLockPressed
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    NSArray *values = @[
        @[@(-1), TGLocalized(@"PasscodeSettings.AutoLock.Disabled")],
#ifdef DEBUG
        @[@(5), @"Debug_5seconds"],
#endif
        @[@(1 * 60), TGLocalized(@"PasscodeSettings.AutoLock.IfAwayFor_1minute")],
        @[@(5 * 60), TGLocalized(@"PasscodeSettings.AutoLock.IfAwayFor_5minutes")],
        @[@(1 * 60 * 60), TGLocalized(@"PasscodeSettings.AutoLock.IfAwayFor_1hour")],
        @[@(5 * 60 * 60), TGLocalized(@"PasscodeSettings.AutoLock.IfAwayFor_5hours")],
    ];
    
    for (NSArray *item in values)
    {
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:item[1] action:[[NSString alloc] initWithFormat:@"%@", item[0]]]];
    }
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"_cancel" type:TGActionSheetActionTypeCancel]];
    __weak TGPasscodeSettingsController *weakSelf = self;
    [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(__unused id target, NSString *action)
    {
        if (![action isEqualToString:@"_cancel"])
        {
            int32_t value = (int32_t)[action intValue];
            [TGAppDelegateInstance setAutomaticLockTimeout:value];
            __strong TGPasscodeSettingsController *strongSelf = weakSelf;
            [strongSelf _updateSections];
        }
    } target:self] showInView:self.view];
}

- (void)touchIdToggled:(bool)value
{
    [self setEnableTouchId:value];
}

- (void)simplePasscodeToggled:(bool)value
{
    if ([self hasPasscode])
    {
        bool passwordWillBeComplex = !value;
        bool passwordIsComplex = ![self passcodeIsSimple];
        
        TGPasscodeEntryControllerMode mode;
        if (passwordIsComplex && passwordWillBeComplex)
            mode = TGPasscodeEntryControllerModeChangeComplexToComplex;
        else if (passwordIsComplex && !passwordWillBeComplex)
            mode = TGPasscodeEntryControllerModeChangeComplexToSimple;
        else if (!passwordIsComplex && passwordWillBeComplex)
            mode = TGPasscodeEntryControllerModeChangeSimpleToComplex;
        else
            mode = TGPasscodeEntryControllerModeChangeSimpleToSimple;
        
        __weak TGPasscodeSettingsController *weakSelf = self;
        TGPasscodeEntryController *controller = [[TGPasscodeEntryController alloc] initWithStyle:TGPasscodeEntryControllerStyleDefault mode:mode cancelEnabled:true allowTouchId:false completion:^(NSString *password)
        {
            __strong TGPasscodeSettingsController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (password != nil)
                {
                    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                    [progressWindow show:true];
                    [TGDatabaseInstance() setPassword:password isStrong:passwordWillBeComplex completion:^
                    {
                        TGDispatchOnMainThread(^
                        {
                            [[TGTelegramNetworking instance] exportCredentialsForExtensions];
                            
                            __strong TGPasscodeSettingsController *strongSelf = weakSelf;
                            [strongSelf _updateSections];
                            [strongSelf dismissViewControllerAnimated:true completion:nil];
                            [progressWindow dismissWithSuccess];
                        });
                    }];
                }
                else
                {
                    [strongSelf _updateSections];
                    [strongSelf dismissViewControllerAnimated:true completion:nil];
                }
            }
        }];
        
        controller.checkCurrentPasscode = ^bool (NSString *passcode)
        {
            return [TGDatabaseInstance() verifyPassword:passcode];
        };
        
        TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            //navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
            //navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        else
            navigationController.restrictLandscape = true;
        [self presentViewController:navigationController animated:true completion:nil];
    }
}

- (void)encryptDataToggled:(bool)value
{
    if ([self hasPasscode])
    {
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [progressWindow show:true];
        [TGDatabaseInstance() setEncryptionEnabled:value completion:^
        {
            TGDispatchOnMainThread(^
            {
                [progressWindow dismissWithSuccess];
            });
        }];
    }
}

@end
