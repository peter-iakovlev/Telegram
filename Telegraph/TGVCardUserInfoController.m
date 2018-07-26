#import "TGVCardUserInfoController.h"

#import <AddressBook/AddressBook.h>
#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/ActionStage.h>

#import <LegacyComponents/TGLocationUtils.h>
#import "TGLegacyComponentsContext.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"
#import "TGApplication.h"
#import "TGAppDelegate.h"
#import "TGInterfaceManager.h"

#import "TGPhonebookNumber.h"

#import "TGSynchronizeContactsActor.h"

#import "TGUserInfoCollectionItem.h"
#import "TGUserInfoPhoneCollectionItem.h"
#import "TGUserInfoButtonCollectionItem.h"
#import "TGUserInfoUsernameCollectionItem.h"
#import "TGUserInfoAddressCollectionItem.h"
#import "TGUserInfoEditingPhoneCollectionItem.h"

#import "TGCustomActionSheet.h"

#import <MessageUI/MessageUI.h>

#import "TGPresentation.h"

#import "TGContactsController.h"
#import "TGCreateContactController.h"
#import "TGAddToExistingContactController.h"

#import "TGUserAvatarGalleryModel.h"
#import "TGUserAvatarGalleryItem.h"

@interface TGVCardUserInfoController () <MFMessageComposeViewControllerDelegate, TGUserInfoEditingPhoneCollectionItemDelegate>
{
    TGUser *_user;
    TGVCard *_vcard;
    NSArray *_phoneNumbers;
    
    TGUserInfoButtonCollectionItem *_inviteItem;
    
    TGUserInfoButtonCollectionItem *_addContactItem;
    
    void (^_forwardWithCompletion)(TGUser *);
}
@end

@implementation TGVCardUserInfoController

- (instancetype)initWithUser:(TGUser *)user vcard:(TGVCard *)vcard
{
    return [self initWithUser:user vcard:vcard forwardWithCompletion:nil];
}

- (instancetype)initWithUser:(TGUser *)user vcard:(TGVCard *)vcard forwardWithCompletion:(void (^)(TGUser *))forwardWithCompletion
{
    self = [super init];
    if (self != nil)
    {
        _user = user;
        _forwardWithCompletion = [forwardWithCompletion copy];
        
        [self setTitleText:TGLocalized(@"ContactInfo.Title")];

        self.userInfoItem.multilineName = true;
        
        if (vcard != nil)
            [self setupWithVCard:vcard];
        else
            [self setupWithUser:user];
        
        if (_forwardWithCompletion == nil)
        {
            if (user.uid > 0) {
                TGUserInfoButtonCollectionItem *sendItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.SendMessage") action:@selector(sendMessagePressed)];
                [self.menuSections addItemToSection:[self indexForSection:self.actionsSection] item:sendItem];
            }
            
            bool isContact = (user.uid != 0 && [TGDatabaseInstance() uidIsRemoteContact:user.uid]) || [TGDatabaseInstance() phonebookContactByPhoneId:phoneMatchHash(user.phoneNumber)] != nil;
            
            if ([TGSynchronizeContactsManager instance].phonebookAccessStatus != TGPhonebookAccessStatusDisabled)
            {
                if (isContact)
                {
                    _addContactItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Profile.AddToExisting") action:@selector(addContactToReallyExistingPressed)];
                    _addContactItem.deselectAutomatically = true;
                    [self.menuSections addItemToSection:[self indexForSection:self.actionsSection] item:_addContactItem];
                }
                else
                {
                    _addContactItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.AddContact") action:@selector(addContactPressed)];
                    _addContactItem.deselectAutomatically = true;
                    [self.menuSections addItemToSection:[self indexForSection:self.actionsSection] item:_addContactItem];
                }
            }
            
            if (user.uid <= 0) {
                _inviteItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.Invite") action:@selector(invitePressed)];
                _inviteItem.deselectAutomatically = true;
                _inviteItem.titleColor = self.presentation.pallete.dialogEncryptedColor;
                [self.menuSections insertItem:_inviteItem toSection:[self indexForSection:self.actionsSection] atIndex:self.actionsSection.items.count];
            }
        
            [self.menuSections deleteSection:[self indexForSection:self.actionsSection]];
            [self.menuSections insertSection:self.actionsSection atIndex:1];
            UIEdgeInsets sectionInsets = self.actionsSection.insets;
            sectionInsets.bottom = 24.0f;
            self.actionsSection.insets = sectionInsets;
        } else {
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"MediaPicker.Send") style:UIBarButtonItemStyleDone target:self action:@selector(sendPressed)]];
        }
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    _inviteItem.titleColor = presentation.pallete.dialogEncryptedColor;
}

- (TGVCard *)vcardForCheckedItems
{
    NSMutableSet *uniqueIds = [[NSMutableSet alloc] init];
    for (TGCollectionMenuSection *section in self.menuSections.sections) {
        for (TGCollectionItem *item in section.items) {
            int64_t uniqueId = 0;
            if ([item isKindOfClass:[TGUserInfoPhoneCollectionItem class]]) {
                TGUserInfoPhoneCollectionItem *phoneItem = (TGUserInfoPhoneCollectionItem *)item;
                if (phoneItem.isChecked || !phoneItem.checking)
                    uniqueId = phoneItem.uniqueId;
            } else if ([item isKindOfClass:[TGUserInfoUsernameCollectionItem class]]) {
                TGUserInfoUsernameCollectionItem *valueItem = (TGUserInfoUsernameCollectionItem *)item;
                if (valueItem.isChecked || !valueItem.checking) {
                    if (valueItem.userInfo[@"uniqueIds"]) {
                        [uniqueIds addObjectsFromArray:valueItem.userInfo[@"uniqueIds"]];
                    } else {
                        uniqueId = valueItem.uniqueId;
                    }
                }
            } else if ([item isKindOfClass:[TGUserInfoAddressCollectionItem class]]) {
                TGUserInfoAddressCollectionItem *addressItem = (TGUserInfoAddressCollectionItem *)item;
                if (addressItem.isChecked || !addressItem.checking)
                    uniqueId = addressItem.uniqueId;
            }
            
            if (uniqueId != 0) {
                [uniqueIds addObject:@(uniqueId)];
            }
        }
    }
    
    return [_vcard vcardByKeepingItemsWithIds:uniqueIds];
}

- (void)sendPressed
{
    if (_forwardWithCompletion == nil)
        return;

    
    TGVCard *resultVCard = [self vcardForCheckedItems];
    
    bool hasCurrentNumber = false;
    NSString *currentNumber = _user.phoneNumber.length > 7 ? [_user.phoneNumber substringWithRange:NSMakeRange(_user.phoneNumber.length - 7, 7)] : _user.phoneNumber;
    NSString *firstNumber = nil;
    for (TGVCardValueArrayItem *phone in resultVCard.phones.values) {
        NSString *number = [TGPhoneUtils cleanPhone:phone.value];
        if (!hasCurrentNumber && [TGVCardUserInfoController comparePhone:currentNumber otherPhone:number])
            hasCurrentNumber = true;
        
        if (firstNumber == nil)
            firstNumber = phone.value;
    }
    
    NSString *vcard = resultVCard.vcardString;
    
    TGUser *resultUser = [_user copy];
    if (!hasCurrentNumber) {
        resultUser.phoneNumber = firstNumber;
        resultUser.uid = 0;
    }
    if (vcard != nil) {
        resultUser.customProperties = @{ @"vcard": vcard };
    }
    
    _forwardWithCompletion(resultUser);
}

+ (bool)comparePhone:(NSString *)firstPhone otherPhone:(NSString *)secondPhone
{
    NSString *firstNumber = firstPhone.length > 7 ? [firstPhone substringWithRange:NSMakeRange(firstPhone.length - 7, 7)] : firstPhone;
    NSString *secondNumber = secondPhone.length > 7 ? [secondPhone substringWithRange:NSMakeRange(secondPhone.length - 7, 7)] : secondPhone;
    return [firstNumber isEqualToString:secondNumber];
}

- (void)setupWithUser:(TGUser *)user {
    self.userInfoItem.automaticallyManageUserPresence = false;
    [self.userInfoItem setUser:user animated:false];
    
    TGUserInfoPhoneCollectionItem *phoneItem = [[TGUserInfoPhoneCollectionItem alloc] initWithLabel:TGLocalized(@"ContactInfo.PhoneLabelMobile") phone:user.phoneNumber phoneColor:self.presentation.pallete.collectionMenuAccentColor action:@selector(phonePressed:)];
    phoneItem.lastInList = true;
    [self.menuSections insertItem:phoneItem toSection:[self indexForSection:self.phonesSection] atIndex:self.phonesSection.items.count];
    
    if (user.phoneNumber != nil)
        _phoneNumbers = @[ [[TGPhonebookNumber alloc] initWithPhone:user.phoneNumber label:TGLocalized(@"ContactInfo.PhoneLabelMobile")] ];
}

- (void)setupWithVCard:(TGVCard *)vcard {
    [self setupWithVCard:vcard skipPhones:nil];
}

- (void)setupWithVCard:(TGVCard *)vcard skipPhones:(NSArray *)skipPhones {
    bool checking = _forwardWithCompletion != nil || skipPhones != nil;
    bool creating = skipPhones != nil;
    _vcard = vcard;
    
    NSString *prefix = _vcard.prefix.value;
    NSString *firstName = _vcard.firstName.value;
    NSString *middleName = _vcard.middleName.value;
    NSString *lastName = _vcard.lastName.value;
    NSString *suffix = _vcard.suffix.value;
    
    if (firstName.length == 0 && lastName.length == 0)
    {
        firstName = _user.realFirstName;
        lastName = _user.realLastName;
    }
    
    NSMutableDictionary *nameComponents = [[NSMutableDictionary alloc] init];
    if (prefix.length > 0)
        nameComponents[@"prefix"] = prefix;
    if (middleName.length > 0)
        nameComponents[@"middleName"] = middleName;
    if (suffix.length > 0)
        nameComponents[@"suffix"] = suffix;
    
    NSString *organization = _vcard.organization.value;
    NSString *jobTitle = _vcard.jobTitle.value;
    NSString *department = _vcard.department.value;
    
    NSMutableArray *jobComponents = [[NSMutableArray alloc] init];
    if (organization.length > 0)
        [jobComponents addObject:organization];
    if (jobTitle.length > 0)
        [jobComponents addObject:jobTitle];
    if (checking && department.length > 0)
        [jobComponents addObject:department];
    
    if (firstName.length == 0 && lastName.length == 0 && organization.length > 0) {
        firstName = organization;
        jobComponents = nil;
    }
    
    TGUser *user = [[TGUser alloc] init];
    user.firstName = firstName;
    user.lastName = lastName;
    user.customProperties = nameComponents;
    if (_user.photoUrlSmall.length > 0)
        user.photoUrlSmall = _user.photoUrlSmall;
    
    self.userInfoItem.automaticallyManageUserPresence = false;
    [self.userInfoItem setUser:user animated:false];
    
    if (!checking && jobComponents != nil) {
        self.userInfoItem.customStatus = [jobComponents componentsJoinedByString:@" - "];
    }
    
    NSMutableArray *phones = [[NSMutableArray alloc] init];
    
    void (^visualizeValue)(TGVCardValue *, SEL) = ^(TGVCardValue *value, SEL action) {
        TGCollectionMenuSection *section = nil;
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        ABPropertyID property = value.property;
        if (property == kABPersonPhoneProperty) {
            section = self.phonesSection;
        }
        
        if ([value isKindOfClass:[TGVCardValueString class]]) {
            
        }
        else if ([value isKindOfClass:[TGVCardValueDate class]]) {
            TGVCardValueDate *valueDate = (TGVCardValueDate *)value;
            
            NSString *labelString = property == kABPersonBirthdayProperty ? TGLocalized(@"ContactInfo.BirthdayLabel") : @"";
            NSString *valueString = nil;
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:valueDate.value];
            if (components.year == 1604) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MMMM dd"];
                valueString = [dateFormatter stringFromDate:valueDate.value];
            }
            else {
                valueString = [NSDateFormatter localizedStringFromDate:valueDate.value dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
            }
            
            TGUserInfoUsernameCollectionItem *item = [[TGUserInfoUsernameCollectionItem alloc] initWithLabel:labelString username:valueString];
            item.action = action;
            item.userInfo = @{ @"date": valueDate.value };
            item.checking = checking;
            item.isChecked = item.checking;
            item.lastInList = true;
            item.uniqueId = value.uniqueId;
            
            [items addObject:item];
        } else if ([value isKindOfClass:[TGVCardValueArray class]]) {
            TGVCardValueArray *valueArray = (TGVCardValueArray *)value;
            
            if (property == kABPersonPhoneProperty) {
                [valueArray.values enumerateObjectsUsingBlock:^(TGVCardValueArrayItem *value, NSUInteger index, __unused BOOL *stop) {
                    NSString *labelString = [TGContactsController localizedLabel:value.label];
                    NSString *valueString = value.value;
                    
                    bool dontFormat = true;
                    NSCharacterSet *letterChars = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"];
                    if ([valueString.uppercaseString rangeOfCharacterFromSet:letterChars].location == NSNotFound) {
                        valueString = [TGPhoneUtils cleanInternationalPhone:valueString forceInternational:false];
                        dontFormat = false;
                    }
                    
                    bool skip = false;
                    for (NSString *phoneNumber in skipPhones)
                    {
                        if ([TGVCardUserInfoController comparePhone:phoneNumber otherPhone:valueString]) {
                            skip = true;
                        }
                    }
                    
                    if (skip)
                        return;
                    
                    if (creating)
                    {
                        TGUserInfoEditingPhoneCollectionItem *item = [[TGUserInfoEditingPhoneCollectionItem alloc] init];
                        item.delegate = self;
                        item.label = labelString;
                        item.phone = valueString;
                        
                        [items addObject:item];
                    }
                    else
                    {
                        NSString *phoneValue = valueString;
                        if ([TGVCardUserInfoController comparePhone:phoneValue otherPhone:_user.phoneNumber])
                            phoneValue = _user.phoneNumber;
                        TGUserInfoPhoneCollectionItem *item = dontFormat ? [[TGUserInfoPhoneCollectionItem alloc] initWithLabel:labelString phone:phoneValue formattedPhone:phoneValue phoneColor:self.presentation.pallete.collectionMenuAccentColor action:action] : [[TGUserInfoPhoneCollectionItem alloc] initWithLabel:labelString phone:phoneValue phoneColor:self.presentation.pallete.collectionMenuAccentColor action:action];
                        
                        item.checking = checking;
                        item.isChecked = item.checking;
                        __weak TGVCardUserInfoController *weakSelf = self;
                        item.isCheckedChanged = ^(__unused bool checked)
                        {
                            __strong TGVCardUserInfoController *strongSelf = weakSelf;
                            if (strongSelf != nil)
                                [strongSelf checkPhonesChecked];
                        };
                        item.uniqueId = value.uniqueId;
                        
                        if (index == valueArray.values.count - 1)
                            item.lastInList = true;
                        
                        [items addObject:item];
                        
                        TGPhonebookNumber *phoneNumber = [[TGPhonebookNumber alloc] initWithPhone:valueString label:labelString];
                        [phones addObject:phoneNumber];
                    }
                }];
            } else if (property == kABPersonURLProperty || property == kABPersonEmailProperty) {
                [valueArray.values enumerateObjectsUsingBlock:^(TGVCardValueArrayItem *value, NSUInteger index, __unused BOOL *stop) {
                    NSString *labelString = [TGContactsController localizedLabel:value.label];
                    NSString *valueString = value.value;
                    
                    TGUserInfoUsernameCollectionItem *item = [[TGUserInfoUsernameCollectionItem alloc] initWithLabel:labelString username:valueString];
                    item.action = action;
                    if (property == kABPersonURLProperty) {
                        item.userInfo = @{ @"url": valueString };
                    } else if (property == kABPersonEmailProperty) {
                        item.userInfo = @{ @"email": valueString };
                    }
                    item.checking = checking;
                    item.isChecked = item.checking;
                    item.uniqueId = value.uniqueId;
                    
                    if (index == valueArray.values.count - 1)
                        item.lastInList = true;

                    [items addObject:item];
                }];
            } else if (property == kABPersonAddressProperty) {
                [valueArray.values enumerateObjectsUsingBlock:^(TGVCardValueArrayItem *value, __unused NSUInteger index, __unused BOOL *stop) {
                    NSString *labelString = [TGContactsController localizedLabel:value.label];
                    NSDictionary *valueDictionary = value.value;
                    
                    NSMutableArray *addressComponents = [[NSMutableArray alloc] init];
                    NSArray *keys = @[ @"Street", @"City", @"State", @"Country", @"ZIP" ];
                    
                    for (NSString *key in keys) {
                        if ([valueDictionary[key] length] > 0)
                            [addressComponents addObject:valueDictionary[key]];
                    }
                    
                    NSString *valueString = [addressComponents componentsJoinedByString:@"\n"];
                    
                    TGUserInfoAddressCollectionItem *item = [[TGUserInfoAddressCollectionItem alloc] init];
                    item.address = valueDictionary;
                    item.title = labelString;
                    item.text = valueString;
                    item.deselectAutomatically = true;
                    item.action = action;
                    item.checking = checking;
                    item.isChecked = checking;
                    item.uniqueId = value.uniqueId;
                    
                    [items addObject:item];
                }];
            } else if (property == kABPersonSocialProfileProperty || property == kABPersonInstantMessageProperty) {
                [valueArray.values enumerateObjectsUsingBlock:^(TGVCardValueArrayItem *value, NSUInteger index, __unused BOOL *stop) {
                    NSDictionary *valueDictionary = value.value;
                    NSString *service = valueDictionary[@"service"];
                    NSString *username = valueDictionary[@"username"];
                    
                    NSString *labelString = nil;
                    NSString *valueString = nil;
                    if (property == kABPersonSocialProfileProperty) {
                        labelString = [TGVCardUserInfoController labelForSocialService:service];
                        if ([service isEqualToString:@"twitter"]) {
                            valueString = [NSString stringWithFormat:@"@%@", username];
                        } else {
                            valueString = username;
                        }
                    }
                    else if (property == kABPersonInstantMessageProperty) {
                        labelString = [TGVCardUserInfoController labelForInstantMessenger:service];
                        valueString = valueDictionary[@"username"];
                    }
                    
                    TGUserInfoUsernameCollectionItem *item = [[TGUserInfoUsernameCollectionItem alloc] initWithLabel:labelString username:valueString];
                    item.action = action;
                    item.userInfo = valueDictionary;
                    item.checking = checking;
                    item.isChecked = item.checking;
                    item.uniqueId = value.uniqueId;
                    
                    if (index == valueArray.values.count - 1)
                        item.lastInList = true;
                    
                    [items addObject:item];
                }];
            }
        }
        
        if (section == nil) {
            TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:items];
            UIEdgeInsets sectionInsets = section.insets;
            sectionInsets.bottom = 0.0f;
            section.insets = sectionInsets;
            [self.menuSections insertSection:section atIndex:[self indexForSection:self.usernameSection]];
        }
        else {
            NSUInteger sectionIndex = [self indexForSection:section];
            NSUInteger index = creating ? MAX(0, (NSInteger)section.items.count - 1) : section.items.count;
            for (TGCollectionItem *item in items ){
                [self.menuSections insertItem:item toSection:sectionIndex atIndex:index];
                index++;
            }
        }
    };
    
    _phoneNumbers = phones;
    
    if (checking && jobComponents.count > 0) {
        NSMutableArray *uniqueIds = [[NSMutableArray alloc] init];
        if (_vcard.organization != nil)
            [uniqueIds addObject:@(_vcard.organization.uniqueId)];
        if (_vcard.jobTitle != nil)
            [uniqueIds addObject:@(_vcard.jobTitle.uniqueId)];
        if (_vcard.department != nil)
            [uniqueIds addObject:@(_vcard.department.uniqueId)];

        TGUserInfoUsernameCollectionItem *item = [[TGUserInfoUsernameCollectionItem alloc] initWithLabel:TGLocalized(@"ContactInfo.Job") username:[jobComponents componentsJoinedByString:@" - "]];
        item.userInfo = @{ @"uniqueIds": uniqueIds };
        item.checking = checking;
        item.isChecked = item.checking;
        item.lastInList = true;
        
        TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:@[item]];
        UIEdgeInsets sectionInsets = section.insets;
        sectionInsets.bottom = 0.0f;
        section.insets = sectionInsets;
        [self.menuSections insertSection:section atIndex:creating ? [self indexForSection:self.usernameSection] : [self indexForSection:self.phonesSection]];
    }
    
    visualizeValue(_vcard.phones, @selector(phonePressed:));
    visualizeValue(_vcard.emails, @selector(emailPressed:));
    visualizeValue(_vcard.urls, @selector(urlPressed:));
    visualizeValue(_vcard.addresses, @selector(addressPressed:));
    visualizeValue(_vcard.birthday, @selector(birthdayPressed:));
    visualizeValue(_vcard.socialProfiles, @selector(socialPressed:));
    visualizeValue(_vcard.instantMessengers, @selector(urlPressed:));
}

+ (NSString *)labelForSocialService:(NSString *)service {
    NSString *label = service;
    if ([service isEqualToString:(NSString *)kABPersonSocialProfileServiceTwitter])
        label = @"Twitter";
    else if ([service isEqualToString:(NSString *)kABPersonSocialProfileServiceFacebook])
        label = @"Facebook";
    else if ([service isEqualToString:(NSString *)kABPersonSocialProfileServiceFlickr])
        label = @"Flickr";
    else if ([service isEqualToString:(NSString *)kABPersonSocialProfileServiceLinkedIn])
        label = @"LinkedIn";
    else if ([service isEqualToString:(NSString *)kABPersonSocialProfileServiceMyspace])
        label = @"Myspace";
    else if ([service isEqualToString:(NSString *)kABPersonSocialProfileServiceSinaWeibo])
        label = @"Sina Weibo";
    return label;
}

+ (NSString *)labelForInstantMessenger:(NSString *)service {
    NSString *label = service;
    if ([service isEqualToString:(NSString *)kABPersonInstantMessageServiceFacebook])
        label = @"Facebook Messenger";
    else if ([service isEqualToString:(NSString *)kABPersonInstantMessageServiceGoogleTalk])
        label = @"Google Talk";
    else if ([service isEqualToString:(NSString *)kABPersonInstantMessageServiceGaduGadu])
        label = @"Gadu-Gadu";
    else if ([service isEqualToString:(NSString *)kABPersonInstantMessageServiceMSN])
        label = @"MSN Messenger";
    else if ([service isEqualToString:(NSString *)kABPersonInstantMessageServiceYahoo])
        label = @"Yahoo! Messenger";
    return label;
}

- (void)checkPhonesChecked
{
    bool hasChecked = false;
    for (TGUserInfoPhoneCollectionItem *item in self.phonesSection.items) {
        if (item.isChecked) {
            hasChecked = true;
            break;
        }
    }
    
    self.navigationItem.rightBarButtonItem.enabled = hasChecked;
}

- (void)phonePressed:(TGUserInfoPhoneCollectionItem *)item
{
    for (TGUserInfoPhoneCollectionItem *phoneItem in self.phonesSection.items)
    {
        if (item == phoneItem)
        {
            NSString *phone = [TGPhoneUtils formatPhoneUrl:phoneItem.phone];
            NSURL *url = [NSURL URLWithString:phone];
            if (url == nil) {
                phone = [TGPhoneUtils cleanInternationalPhone:phone forceInternational:[phone hasPrefix:@"+"]];
                url = [NSURL URLWithString:phone];
            }
            
            TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
            controller.dismissesByOutsideTap = true;
            controller.hasSwipeGesture = true;
            
            __weak TGMenuSheetController *weakController = controller;
            __weak TGVCardUserInfoController *weakSelf = self;
            TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController != nil)
                    [strongController dismissAnimated:true];
            }];
            
            TGMenuSheetTitleItemView *titleItem = [[TGMenuSheetTitleItemView alloc] initWithTitle:nil subtitle:[TGPhoneUtils formatPhone:phoneItem.phone forceInternational:false]];
            
            if (_user.uid > 0 && [TGVCardUserInfoController comparePhone:_user.phoneNumber otherPhone:phoneItem.phone])
            {
                TGMenuSheetButtonItemView *telegramItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"UserInfo.TelegramCall") type:TGMenuSheetButtonTypeDefault action:^
                {
                    __strong TGVCardUserInfoController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                        [[TGInterfaceManager instance] callPeerWithId:strongSelf->_user.uid];
                    
                    __strong TGMenuSheetController *strongController = weakController;
                    if (strongController != nil)
                        [strongController dismissAnimated:true];
                }];
                
                TGMenuSheetButtonItemView *phoneItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"UserInfo.PhoneCall") type:TGMenuSheetButtonTypeDefault action:^
                {
                    [TGAppDelegateInstance performPhoneCall:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"tel:%@", phone]]];
                    __strong TGMenuSheetController *strongController = weakController;
                    if (strongController != nil)
                        [strongController dismissAnimated:true];
                }];
                
                [controller setItemViews:@[ titleItem, telegramItem, phoneItem, cancelItem ]];
            }
            else
            {
                TGMenuSheetButtonItemView *phoneItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.Call") type:TGMenuSheetButtonTypeDefault action:^
                {
                    [TGAppDelegateInstance performPhoneCall:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"tel:%@", phone]]];
                    __strong TGMenuSheetController *strongController = weakController;
                    if (strongController != nil)
                        [strongController dismissAnimated:true];
                }];
                
                [controller setItemViews:@[ titleItem, phoneItem, cancelItem ]];
            }
            
            controller.sourceRect = ^
            {
                __strong TGVCardUserInfoController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return CGRectZero;
                
                return [strongSelf sourceRectForPhoneItem:item];
            };
            [controller presentInViewController:self sourceView:self.view animated:true];
            
            break;
        }
    }
}

- (CGRect)sourceRectForPhoneItem:(TGUserInfoPhoneCollectionItem *)phoneItem
{
    for (TGUserInfoPhoneCollectionItem *item in self.phonesSection.items)
    {
        if (item == phoneItem)
        {
            if (item.view != nil)
                return [item.view convertRect:item.view.bounds toView:self.view];
            
            return CGRectZero;
        }
    }
    
    return CGRectZero;
}

- (void)emailPressed:(TGUserInfoUsernameCollectionItem *)sender {
    NSString *email = sender.userInfo[@"email"];
    if (email.length == 0)
        return;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", email]];
    [(TGApplication *)[TGApplication sharedApplication] nativeOpenURL:url];
}

- (void)urlPressed:(TGUserInfoUsernameCollectionItem *)sender {
    NSString *link = sender.userInfo[@"url"];
    if (link.length == 0)
        return;
    
    if (![link hasPrefix:@"http"] && ![link hasPrefix:@"https"])
        link = [NSString stringWithFormat:@"http://%@", link];
    
    NSURL *url = [NSURL URLWithString:link];
    [(TGApplication *)[TGApplication sharedApplication] nativeOpenURL:url];
}

- (void)socialPressed:(TGUserInfoUsernameCollectionItem *)sender {
    NSString *link = sender.userInfo[@"url"];
    if (link.length == 0)
        return;
    
    if (![link hasPrefix:@"http"] && [link hasPrefix:@"https"])
        link = [NSString stringWithFormat:@"http://%@", link];
    
    NSURL *url = [NSURL URLWithString:link];
    [(TGApplication *)[TGApplication sharedApplication] nativeOpenURL:url];
}

- (void)addressPressed:(TGUserInfoAddressCollectionItem *)sender {
    NSString *name = [sender.title capitalizedString];
    [TGLocationUtils openMapsWithCoordinate:sender.placemark.location.coordinate withDirections:false locationName:name];
}

- (void)birthdayPressed:(TGUserInfoUsernameCollectionItem *)sender {
    NSDate *date = sender.userInfo[@"date"];
    NSDate *now = [NSDate date];
    
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [gregorian components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay fromDate:date];
    NSDateComponents *nowComponents = [gregorian components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay fromDate:now];
    
    NSDate *targetDate = now;
    if (dateComponents.month >= nowComponents.month && (dateComponents.day >= nowComponents.day || dateComponents.month > nowComponents.month)) {
        [dateComponents setYear:nowComponents.year];
    }
    else {
        [dateComponents setYear:nowComponents.year + 1];
    }
    targetDate = [gregorian dateFromComponents:dateComponents];
    
    NSInteger interval = (NSInteger)[targetDate timeIntervalSinceReferenceDate];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"calshow:%ld", interval]];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)sendMessagePressed
{
    [[TGInterfaceManager instance] navigateToConversationWithId:_user.uid conversation:nil];
}

- (void)addContactPressed
{
    [[[TGCustomActionSheet alloc] initWithTitle:nil actions:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Profile.CreateNewContact") action:@"createNewContact"],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Profile.AddToExisting") action:@"addToExisting"],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
    ] actionBlock:^(TGVCardUserInfoController *controller, NSString *action)
    {
        if ([action isEqualToString:@"createNewContact"])
            [controller createContactPressed];
        else if ([action isEqualToString:@"addToExisting"])
            [controller addContactToExistingPressed];
    } target:self] showInView:self.view];
}

- (void)createContactPressed
{
    TGCreateContactController *createContactController = nil;
    if (_user.uid > 0)
        createContactController = [[TGCreateContactController alloc] initWithUid:_user.uid firstName:_user.firstName lastName:_user.lastName phoneNumber:_user.phoneNumber attachment:_user.customProperties[@"contact"]];
    else
        createContactController = [[TGCreateContactController alloc] initWithFirstName:_user.firstName lastName:_user.lastName phoneNumber:_user.phoneNumber attachment:_user.customProperties[@"contact"]];
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[createContactController]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)addContactToExistingPressed
{
    TGAddToExistingContactController *addToExistingController = [[TGAddToExistingContactController alloc] initWithUid:_user.uid phoneNumber:_user.phoneNumber attachment:_user.customProperties[@"contact"]];
    addToExistingController.presentation = self.presentation;
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[addToExistingController]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)addContactToReallyExistingPressed
{
    int nativeContactid = [TGDatabaseInstance() phonebookContactNativeIdByPhoneId:phoneMatchHash(_user.phoneNumber)];
    TGCreateContactController *createContactController = [[TGCreateContactController alloc] initWithUid:_user.uid phoneNumber:_user.phoneNumber existingNativeContactId:nativeContactid attachment:_user.customProperties[@"contact"] modal:true];
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[createContactController]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)invitePressed
{
    if (_phoneNumbers.count == 0)
        return;
    
    if (_phoneNumbers.count == 1)
        [self _inviteWithPhoneNumber:((TGPhonebookNumber *)_phoneNumbers[0]).phone];
    else
    {
        NSMutableArray *actions = [[NSMutableArray alloc] init];
        for (TGPhonebookNumber *phoneNumber in _phoneNumbers)
        {
            if (phoneNumber.phone.length != 0)
            {
                [actions addObject:[[TGActionSheetAction alloc] initWithTitle:[[NSString alloc] initWithFormat:@"%@: %@", phoneNumber.label, [TGPhoneUtils formatPhone:phoneNumber.phone forceInternational:false]] action:phoneNumber.phone]];
            }
        }
        
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
        
        [[[TGCustomActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGVCardUserInfoController *controller, NSString *action)
          {
              if (![action isEqualToString:@"cancel"])
                  [controller _inviteWithPhoneNumber:action];
          } target:self] showInView:self.view];
    }
}

- (void)_inviteWithPhoneNumber:(NSString *)phoneNumber
{
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *messageComposer = [[MFMessageComposeViewController alloc] init];
        
        if (messageComposer != nil)
        {
            messageComposer.recipients = [[NSArray alloc] initWithObjects:phoneNumber, nil];
            messageComposer.messageComposeDelegate = self;
            
            NSString *body = [NSString stringWithFormat:TGLocalized(@"InviteText.SingleContact"), [TGContactsController downloadLink]];
            messageComposer.body = body;
            
            [self presentViewController:messageComposer animated:true completion:nil];
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
        }
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)__unused controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:true completion:nil];
    
    if (result == MessageComposeResultSent)
    {
        @try
        {
            static int inviteAction = 0;
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/auth/sendinvites/(%d)", inviteAction] options:[[NSDictionary alloc] initWithObjectsAndKeys:controller.body, @"text", controller.recipients, @"phones", nil] watcher:TGTelegraphInstance];
        }
        @catch (NSException *exception)
        {
        }
    }
}

- (TGModernGalleryController *)createAvatarGalleryControllerForPreviewMode:(bool)previewMode
{
    TGUser *user = [TGDatabaseInstance() loadUser:_user.uid];
    
    if (user.photoUrlSmall.length != 0)
    {
        TGRemoteImageView *avatarView = [self.userInfoItem visibleAvatarView];
        
        if (user != nil && user.photoUrlBig != nil && avatarView.currentImage != nil)
        {
            TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] initWithContext:[TGLegacyComponentsContext shared]];
            modernGallery.previewMode = previewMode;
            if (previewMode)
                modernGallery.showInterface = false;
            
            modernGallery.model = [[TGUserAvatarGalleryModel alloc] initWithPeerId:_user.uid currentAvatarLegacyThumbnailImageUri:user.photoUrlSmall currentAvatarLegacyImageUri:user.photoUrlBig currentAvatarImageSize:CGSizeMake(640.0f, 640.0f)];
            
            __weak TGVCardUserInfoController *weakSelf = self;
            __weak TGModernGalleryController *weakGallery = modernGallery;
            
            modernGallery.itemFocused = ^(id<TGModernGalleryItem> item)
            {
                __strong TGVCardUserInfoController *strongSelf = weakSelf;
                __strong TGModernGalleryController *strongGallery = weakGallery;
                if (strongSelf != nil)
                {
                    if (strongGallery.previewMode)
                        return;
                    
                    if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
                    {
                        if (((TGUserAvatarGalleryItem *)item).isCurrent)
                        {
                            ((UIView *)strongSelf.userInfoItem.visibleAvatarView).hidden = true;
                        }
                        else
                            ((UIView *)strongSelf.userInfoItem.visibleAvatarView).hidden = false;
                    }
                }
            };
            
            modernGallery.beginTransitionIn = ^UIView *(id<TGModernGalleryItem> item, __unused TGModernGalleryItemView *itemView)
            {
                __strong TGVCardUserInfoController *strongSelf = weakSelf;
                __strong TGModernGalleryController *strongGallery = weakGallery;
                if (strongSelf != nil)
                {
                    if (strongGallery.previewMode)
                        return nil;
                    
                    if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
                    {
                        if (((TGUserAvatarGalleryItem *)item).isCurrent)
                        {
                            return strongSelf.userInfoItem.visibleAvatarView;
                        }
                    }
                }
                
                return nil;
            };
            
            modernGallery.beginTransitionOut = ^UIView *(id<TGModernGalleryItem> item, __unused TGModernGalleryItemView *itemView)
            {
                __strong TGVCardUserInfoController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
                    {
                        if (((TGUserAvatarGalleryItem *)item).isCurrent)
                        {
                            return strongSelf.userInfoItem.visibleAvatarView;
                        }
                    }
                }
                
                return nil;
            };
            
            modernGallery.completedTransitionOut = ^
            {
                __strong TGVCardUserInfoController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    ((UIView *)strongSelf.userInfoItem.visibleAvatarView).hidden = false;
                }
            };
            
            if (!previewMode)
            {
                TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithManager:[[TGLegacyComponentsContext shared] makeOverlayWindowManager] parentController:self contentController:modernGallery];
                controllerWindow.hidden = false;
            }
            else
            {
                CGFloat side = MIN(self.view.frame.size.width, self.view.frame.size.height);
                modernGallery.preferredContentSize = CGSizeMake(side, side);
            }
            
            return modernGallery;
        }
    }
    
    return nil;
}


- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"avatarTapped"] && [self isMemberOfClass:[TGVCardUserInfoController class]])
        [self createAvatarGalleryControllerForPreviewMode:false];
    
    [super actionStageActionRequested:action options:options];
}

@end
