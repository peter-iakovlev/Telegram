/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGForwardContactPickerController.h"

#import <LegacyComponents/LegacyComponents.h>

#import <AddressBook/AddressBook.h>

#import "TGDatabase.h"

#import "TGCustomActionSheet.h"

#import "TGVCardUserInfoController.h"

#import "TGPresentation.h"

@interface TGForwardContactPickerController ()

@end

@implementation TGForwardContactPickerController

- (instancetype)init
{
    self = [super initWithContactsMode:TGContactsModeRegistered | TGContactsModePhonebook | TGContactsModeCombineSections | TGContactsModeShowSelf | TGContactsModeShare];
    if (self != nil)
    {
        self.presentation = TGPresentation.current;
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
    }
    return self;
}

- (void)cancelPressed
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)singleUserSelected:(TGUser *)user
{
    [self deselectRow];
    
    TGPhonebookContact *contact = nil;
    
    int nativeId = -1;
    if (user.uid < 0)
    {
        nativeId = -user.uid;
        contact = [TGDatabaseInstance() phonebookContactByNativeId:nativeId];
    }
    else
    {
        contact = [TGDatabaseInstance() phonebookContactByPhoneId:phoneMatchHash(user.phoneNumber)];
        nativeId = [TGDatabaseInstance() phonebookContactNativeIdByPhoneId:phoneMatchHash(user.phoneNumber)];
    }
    
    NSString *vcardString = nil;
    if (nativeId != -1)
    {
        ABAddressBookRef book = ABAddressBookCreate();
        ABRecordRef ref = ABAddressBookGetPersonWithRecordID(book, nativeId);
        
        if (ref != NULL)
        {
            ABRecordRef people[1] = {
                CFRetain(ref)
            };
            
            CFArrayRef peopleArray = CFArrayCreate(kCFAllocatorDefault, (const void **)&people, 1, NULL);
            
            NSData *vCardData = (__bridge NSData *)(ABPersonCreateVCardRepresentationWithPeople(peopleArray));
            vcardString = [[NSString alloc] initWithData:vCardData encoding:NSUTF8StringEncoding];
            
            CFRelease(peopleArray);
            CFRelease(ref);
        }
        
        CFRelease(book);
    }
    
    TGUser *contactUser = [[TGUser alloc] init];
    contactUser.firstName = contact.firstName;
    contactUser.lastName = contact.lastName;
    contactUser.phoneNumber =  user.phoneNumber.length > 0 ? user.phoneNumber : ((TGPhoneNumber *)contact.phoneNumbers.firstObject).number;
    if (user.uid > 0) {
        contactUser.uid = user.uid;
        contactUser.photoUrlSmall = user.photoUrlSmall;
    }
    
    __weak TGForwardContactPickerController *weakSelf = self;
    void (^completionWithUser)(TGUser *) = ^(TGUser *user) {
        __strong TGForwardContactPickerController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf.presentingViewController dismissViewControllerAnimated:true completion:nil];
        
        id<TGForwardContactPickerControllerDelegate> delegate = _delegate;
        if ([delegate respondsToSelector:@selector(forwardContactPickerController:didSelectContact:)])
            [delegate forwardContactPickerController:strongSelf didSelectContact:user];
    };
    
    TGVCard *vcard = [[TGVCard alloc] initWithString:vcardString];
    if (vcard.isPrimitive || self.sendImmediately) {
        completionWithUser(contactUser);
        [self.view endEditing:true];
    } else {
        TGVCardUserInfoController *vcardController = [[TGVCardUserInfoController alloc] initWithUser:contactUser vcard:vcard forwardWithCompletion:completionWithUser];
        [self.navigationController pushViewController:vcardController animated:true];
    }
}

@end
