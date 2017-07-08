/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCreateContactController.h"

#import "ActionStage.h"
#import "TGPhoneUtils.h"
#import "TGStringUtils.h"

#import "TGDatabase.h"

#import "TGUserInfoCollectionItem.h"
#import "TGUserInfoEditingPhoneCollectionItem.h"
#import "TGUserInfoAddPhoneCollectionItem.h"

#import "TGNavigationController.h"
#import "TGPhoneLabelPickerController.h"

#import "TGSynchronizeContactsActor.h"

#import "TGAlertView.h"

@interface TGCreateContactController () <TGUserInfoEditingPhoneCollectionItemDelegate, TGPhoneLabelPickerControllerDelegate>
{
    int32_t _uid;
    TGUser *_user;
    
    TGPhonebookContact *_phonebookInfo;
    int32_t _uidToAdd;
    NSString *_phoneNumberToAdd;
    
    bool _activateNameEditingOnReset;
    
    NSIndexPath *_currentLabelPickerIndexPath;
}

@end

@implementation TGCreateContactController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [self _commonInit:true];
        
        _activateNameEditingOnReset = true;
    }
    return self;
}

- (instancetype)initWithUid:(int32_t)uid firstName:(NSString *)firstName lastName:(NSString *)lastName phoneNumber:(NSString *)phoneNumber
{
    self = [super init];
    if (self != nil)
    {
        [self _commonInit:true];
        
        _uid = uid;
        _user = [[TGDatabaseInstance() loadUser:_uid] copy];
        _user.firstName = firstName;
        _user.lastName = lastName;
        _user.phoneNumber = phoneNumber;
        
        [self.userInfoItem setUser:_user animated:false];
        self.navigationItem.rightBarButtonItem.enabled = firstName.length != 0 || lastName.length != 0;
        
        if (phoneNumber.length != 0)
        {
            TGUserInfoEditingPhoneCollectionItem *phoneItem = [[TGUserInfoEditingPhoneCollectionItem alloc] init];
            phoneItem.delegate = self;
            phoneItem.label = [[TGSynchronizeContactsManager phoneLabels] firstObject];
            phoneItem.phone = phoneNumber;
            
            NSUInteger phonesSectionIndex = [self indexForSection:self.phonesSection];
            if (phonesSectionIndex != NSNotFound)
            {
                [self.menuSections beginRecordingChanges];
                [self.menuSections insertItem:phoneItem toSection:phonesSectionIndex atIndex:MAX(0, (NSInteger)self.phonesSection.items.count - 1)];
                [self.menuSections commitRecordedChanges:self.collectionView];
                
                [phoneItem makePhoneFieldFirstResponder];
            }
        }
    }
    return self;
}

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName phoneNumber:(NSString *)phoneNumber
{
    self = [super init];
    if (self != nil)
    {
        [self _commonInit:true];
        
        _user = [[TGUser alloc] init];
        _user.firstName = firstName;
        _user.lastName = lastName;
        _user.phoneNumber = phoneNumber;
        
        firstName = [firstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (firstName.length == 0 && phoneNumber.length > 0)
            _activateNameEditingOnReset = true;
        
        [self.userInfoItem setUser:_user animated:false];
        self.navigationItem.rightBarButtonItem.enabled = firstName.length != 0 || lastName.length != 0;
        
        if (phoneNumber.length != 0)
        {
            TGUserInfoEditingPhoneCollectionItem *phoneItem = [[TGUserInfoEditingPhoneCollectionItem alloc] init];
            phoneItem.delegate = self;
            phoneItem.label = [[TGSynchronizeContactsManager phoneLabels] firstObject];
            phoneItem.phone = phoneNumber;
            
            NSUInteger phonesSectionIndex = [self indexForSection:self.phonesSection];
            if (phonesSectionIndex != NSNotFound)
            {
                [self.menuSections beginRecordingChanges];
                [self.menuSections insertItem:phoneItem toSection:phonesSectionIndex atIndex:MAX(0, (NSInteger)self.phonesSection.items.count - 1)];
                [self.menuSections commitRecordedChanges:self.collectionView];
                
                [phoneItem makePhoneFieldFirstResponder];
            }
        }
    }
    return self;
}

- (instancetype)initWithUid:(int32_t)uid phoneNumber:(NSString *)phoneNumber existingUid:(int32_t)existingUid
{
    self = [super init];
    if (self != nil)
    {
        [self _commonInit:false];
        
        _uid = existingUid;
        _user = [[TGDatabaseInstance() loadUser:existingUid] copy];
        _phonebookInfo = [TGDatabaseInstance() phonebookContactByPhoneId:phoneMatchHash(_user.phoneNumber)];
        
        _uidToAdd =  uid;
        _phoneNumberToAdd = phoneNumber;
        
        [self.userInfoItem setUser:_user animated:false];
        self.navigationItem.rightBarButtonItem.enabled = _user.firstName.length != 0 || _user.lastName.length != 0;
        
        NSMutableArray *existingLabels = [[NSMutableArray alloc] initWithArray:[TGSynchronizeContactsManager phoneLabels]];
        for (TGPhoneNumber *number in _phonebookInfo.phoneNumbers)
        {
            TGUserInfoEditingPhoneCollectionItem *phoneItem = [[TGUserInfoEditingPhoneCollectionItem alloc] init];
            phoneItem.delegate = self;
            phoneItem.label = number.label;
            phoneItem.phone = number.number;
            
            if (number.label != nil)
                [existingLabels removeObject:number.label];
            
            NSUInteger phonesSectionIndex = [self indexForSection:self.phonesSection];
            if (phonesSectionIndex != NSNotFound)
            {
                [self.menuSections beginRecordingChanges];
                [self.menuSections insertItem:phoneItem toSection:phonesSectionIndex atIndex:MAX(0, (NSInteger)self.phonesSection.items.count - 1)];
                [self.menuSections commitRecordedChanges:self.collectionView];
                
                [phoneItem makePhoneFieldFirstResponder];
            }
        }
        
        if (phoneNumber.length != 0)
        {
            TGUserInfoEditingPhoneCollectionItem *phoneItem = [[TGUserInfoEditingPhoneCollectionItem alloc] init];
            phoneItem.delegate = self;
            phoneItem.label = existingLabels.count != 0 ? [existingLabels firstObject] : [[TGSynchronizeContactsManager phoneLabels] lastObject];
            phoneItem.phone = phoneNumber;
            
            NSUInteger phonesSectionIndex = [self indexForSection:self.phonesSection];
            if (phonesSectionIndex != NSNotFound)
            {
                [self.menuSections beginRecordingChanges];
                [self.menuSections insertItem:phoneItem toSection:phonesSectionIndex atIndex:MAX(0, (NSInteger)self.phonesSection.items.count - 1)];
                [self.menuSections commitRecordedChanges:self.collectionView];
                
                [phoneItem makePhoneFieldFirstResponder];
            }
        }
    }
    return self;
}

- (instancetype)initWithUid:(int32_t)uid phoneNumber:(NSString *)phoneNumber existingNativeContactId:(int)existingNativeContactId
{
    self = [super init];
    if (self != nil)
    {
        [self _commonInit:false];
        
        _phonebookInfo = [TGDatabaseInstance() phonebookContactByNativeId:existingNativeContactId];
        _user = [[TGUser alloc] init];
        _user.firstName = _phonebookInfo.firstName;
        _user.lastName = _phonebookInfo.lastName;
        
        _uidToAdd =  uid;
        _phoneNumberToAdd = phoneNumber;
        
        self.userInfoItem.disableAvatar = true;
        [self.userInfoItem setUser:_user animated:false];
        self.navigationItem.rightBarButtonItem.enabled = _user.firstName.length != 0 || _user.lastName.length != 0;
        
        NSMutableArray *existingLabels = [[NSMutableArray alloc] initWithArray:[TGSynchronizeContactsManager phoneLabels]];
        for (TGPhoneNumber *number in _phonebookInfo.phoneNumbers)
        {
            TGUserInfoEditingPhoneCollectionItem *phoneItem = [[TGUserInfoEditingPhoneCollectionItem alloc] init];
            phoneItem.delegate = self;
            phoneItem.label = number.label;
            phoneItem.phone = number.number;
            
            if (number.label != nil)
                [existingLabels removeObject:number.label];
            
            NSUInteger phonesSectionIndex = [self indexForSection:self.phonesSection];
            if (phonesSectionIndex != NSNotFound)
            {
                [self.menuSections beginRecordingChanges];
                [self.menuSections insertItem:phoneItem toSection:phonesSectionIndex atIndex:MAX(0, (NSInteger)self.phonesSection.items.count - 1)];
                [self.menuSections commitRecordedChanges:self.collectionView];
                
                [phoneItem makePhoneFieldFirstResponder];
            }
        }
        
        if (phoneNumber.length != 0)
        {
            TGUserInfoEditingPhoneCollectionItem *phoneItem = [[TGUserInfoEditingPhoneCollectionItem alloc] init];
            phoneItem.delegate = self;
            phoneItem.label = existingLabels.count != 0 ? [existingLabels firstObject] : [[TGSynchronizeContactsManager phoneLabels] lastObject];
            phoneItem.phone = phoneNumber;
            
            NSUInteger phonesSectionIndex = [self indexForSection:self.phonesSection];
            if (phonesSectionIndex != NSNotFound)
            {
                [self.menuSections beginRecordingChanges];
                [self.menuSections insertItem:phoneItem toSection:phonesSectionIndex atIndex:MAX(0, (NSInteger)self.phonesSection.items.count - 1)];
                [self.menuSections commitRecordedChanges:self.collectionView];
                
                [phoneItem makePhoneFieldFirstResponder];
            }
        }
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:true];
}

- (void)_commonInit:(bool)isModal
{
    [self setTitleText:TGLocalized(@"NewContact.Title")];
    if (isModal)
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
    self.navigationItem.rightBarButtonItem.enabled = false;
    
    UIEdgeInsets phonesSectionInsets = self.phonesSection.insets;
    phonesSectionInsets.top += 32.0f;
    self.phonesSection.insets = phonesSectionInsets;
    
    [self.userInfoItem setEditing:true animated:false];
    
    NSUInteger phonesSectionIndex = [self indexForSection:self.phonesSection];
    if (phonesSectionIndex != NSNotFound)
    {
        [self.menuSections insertItem:[[TGUserInfoAddPhoneCollectionItem alloc] initWithAction:@selector(addPhonePressed)] toSection:phonesSectionIndex atIndex:0];
    }
}

- (void)_resetCollectionView
{
    [super _resetCollectionView];
    
    if ([self.collectionView respondsToSelector:@selector(setKeyboardDismissMode:)])
        self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    if (_activateNameEditingOnReset)
    {
        _activateNameEditingOnReset = false;
        
        [self.collectionView layoutSubviews];
        [self.userInfoItem makeNameFieldFirstResponder];
    }
    
    [self enterEditingMode:false];
}

- (void)cancelPressed
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)donePressed
{
    if (!self.view.userInteractionEnabled)
        return;
    
    self.view.userInteractionEnabled = false;
    
    int matchHash = phoneMatchHash(_user.phoneNumber);
    bool hasCurrentNumber = false;
    
    NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
    for (id item in self.phonesSection.items)
    {
        if ([item isKindOfClass:[TGUserInfoEditingPhoneCollectionItem class]])
        {
            TGUserInfoEditingPhoneCollectionItem *phoneItem = item;
            if (phoneItem.phone.length != 0)
            {
                [phoneNumbers addObject:[[TGPhoneNumber alloc] initWithLabel:phoneItem.label number:phoneItem.phone]];
                if (!hasCurrentNumber && phoneMatchHash(phoneItem.phone) == matchHash)
                    hasCurrentNumber = true;
            }
        }
    }
    
    if (_phonebookInfo != nil)
        [self changePhoneNumbers:phoneNumbers removedMainPhone:false];
    else
    {
        TGPhonebookContact *phonebookContact = [[TGPhonebookContact alloc] init];
        phonebookContact.firstName = self.userInfoItem.editingFirstName == nil ? @"" : self.userInfoItem.editingFirstName;
        phonebookContact.lastName = self.userInfoItem.editingLastName == nil ? @"" : self.userInfoItem.editingLastName;
        phonebookContact.phoneNumbers = phoneNumbers;
        
        static int actionId = 0;
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/synchronizeContacts/(%d,%d,addContactLocal)", _uid, actionId++] options:[NSDictionary dictionaryWithObjectsAndKeys:phonebookContact, @"contact", [[NSNumber alloc] initWithInt:hasCurrentNumber ? _uid : 0], @"uid", nil] watcher:self];
    }
}

- (void)addPhonePressed
{
    NSMutableArray *possibleLabels = [[NSMutableArray alloc] initWithArray:[TGSynchronizeContactsManager phoneLabels]];
    
    for (id item in self.phonesSection.items)
    {
        if ([item isKindOfClass:[TGUserInfoEditingPhoneCollectionItem class]])
        {
            TGUserInfoEditingPhoneCollectionItem *phoneItem = item;
            if (phoneItem.label != nil)
                [possibleLabels removeObject:phoneItem.label];
        }
    }
    
    TGUserInfoEditingPhoneCollectionItem *phoneItem = [[TGUserInfoEditingPhoneCollectionItem alloc] init];
    phoneItem.delegate = self;
    phoneItem.label = possibleLabels.count != 0 ? [possibleLabels firstObject] : [[TGSynchronizeContactsManager phoneLabels] lastObject];
    
    NSUInteger phonesSectionIndex = [self indexForSection:self.phonesSection];
    if (phonesSectionIndex != NSNotFound)
    {
        [self.menuSections beginRecordingChanges];
        [self.menuSections insertItem:phoneItem toSection:phonesSectionIndex atIndex:MAX(0, (NSInteger)self.phonesSection.items.count - 1)];
        [self.menuSections commitRecordedChanges:self.collectionView];
        
        [phoneItem makePhoneFieldFirstResponder];
    }
}

- (void)editingPhoneItemRequestedDelete:(TGUserInfoEditingPhoneCollectionItem *)editingPhoneItem
{
    NSIndexPath *indexPath = [self indexPathForItem:editingPhoneItem];
    if (indexPath != nil)
    {
        [self.menuSections beginRecordingChanges];
        [self.menuSections deleteItemFromSection:indexPath.section atIndex:indexPath.item];
        [self.menuSections commitRecordedChanges:self.collectionView];
    }
}

- (void)editingPhoneItemRequestedLabelSelection:(TGUserInfoEditingPhoneCollectionItem *)editingPhoneItem
{
    NSIndexPath *indexPath = [self indexPathForItem:editingPhoneItem];
    if (indexPath != nil)
    {
        _currentLabelPickerIndexPath = indexPath;
        
        TGPhoneLabelPickerController *labelController = [[TGPhoneLabelPickerController alloc] initWithSelectedLabel:editingPhoneItem.label];
        labelController.delegate = self;
        
        TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[labelController]];
        
        if ([self inPopover])
        {
            navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
            navigationController.presentationStyle = TGNavigationControllerPresentationStyleChildInPopover;
        }
        else if ([self inFormSheet])
        {
            navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
            navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        }
        
        [self presentViewController:navigationController animated:true completion:nil];
    }
}

- (void)phoneLabelPickerController:(TGPhoneLabelPickerController *)__unused phoneLabelPickerController didFinishWithLabel:(NSString *)label
{
    TGUserInfoEditingPhoneCollectionItem *phoneItem = self.phonesSection.items[_currentLabelPickerIndexPath.item];
    phoneItem.label = label;
    
    _currentLabelPickerIndexPath = nil;
}

- (void)changePhoneNumbers:(NSArray *)phoneNumbers removedMainPhone:(bool)removedMainPhone
{
    self.view.userInteractionEnabled = false;
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if ([TGSynchronizeContactsManager instance].phonebookAccessStatus != TGPhonebookAccessStatusEnabled)
        {
            TGDispatchOnMainThread(^
            {
                self.view.userInteractionEnabled = true;
                
                [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Profile.PhonebookAccessDisabled") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil] show];
            });
        }
        else
        {
            TGDispatchOnMainThread(^
            {
                self.view.userInteractionEnabled = true;
            });
            
            static int actionId = 0;
            
            NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
            [options setObject:[[NSNumber alloc] initWithInt:_uid] forKey:@"uid"];
            [options setObject:[[NSNumber alloc] initWithInt:_phonebookInfo.nativeId] forKey:@"nativeId"];
            if (phoneNumbers != nil)
                [options setObject:phoneNumbers forKey:@"phones"];
            
            if (removedMainPhone)
                [options setObject:[[NSNumber alloc] initWithBool:true] forKey:@"removedMainPhone"];
            
            bool found = false;
            NSString *phoneNumberToAdd = [TGPhoneUtils cleanInternationalPhone:_phoneNumberToAdd forceInternational:false];
            for (TGPhoneNumber *phoneNumber in phoneNumbers)
            {
                if ([[TGPhoneUtils cleanInternationalPhone:phoneNumber.number forceInternational:false] isEqualToString:phoneNumberToAdd])
                {
                    found = true;
                    break;
                }
            }
            if (found)
                [options setObject:@(_uidToAdd) forKey:@"addingUid"];
            
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/synchronizeContacts/(%s,%d,changePhonesLocal)", removedMainPhone ? "removedMainPhone" : "", actionId++] options:options watcher:self];
        }
    }];
}


#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"editingNameChanged"])
    {
        self.navigationItem.rightBarButtonItem.enabled = self.userInfoItem.editingFirstName.length != 0 || self.userInfoItem.editingLastName.length != 0;
    }
    
    [super actionStageActionRequested:action options:options];
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasSuffix:@"addContactLocal)"] || [path hasSuffix:@"changePhonesLocal)"])
    {
        TGDispatchOnMainThread(^
        {
            self.view.userInteractionEnabled = true;
            
            id<TGCreateContactControllerDelegate> delegate = _delegate;
            if ([delegate respondsToSelector:@selector(createContactControllerDidFinish:)])
                [delegate createContactControllerDidFinish:self];
            else
                [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
        });
    }
    
    [super actorCompleted:status path:path result:result];
}

@end
