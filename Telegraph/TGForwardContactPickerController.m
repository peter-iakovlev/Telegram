/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGForwardContactPickerController.h"

#import "TGDatabase.h"

@interface TGForwardContactPickerController ()

@end

@implementation TGForwardContactPickerController

- (instancetype)init
{
    self = [super initWithContactsMode:TGContactsModeRegistered | TGContactsModePhonebook | TGContactsModeCombineSections | TGContactsModeShowSelf];
    if (self != nil)
    {
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
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
    
    TGUser *contactUser = user;
    if (user.uid < 0)
    {
        TGPhonebookContact *contact = [TGDatabaseInstance() phonebookContactByNativeId:-user.uid];
        if (contact != nil)
        {
            contactUser = [[TGUser alloc] init];
            contactUser.firstName = contact.firstName;
            contactUser.lastName = contact.lastName;
            contactUser.phoneNumber = ((TGPhoneNumber *)contact.phoneNumbers.firstObject).number;
        }
    }
    
    id<TGForwardContactPickerControllerDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(forwardContactPickerController:didSelectContact:)])
        [delegate forwardContactPickerController:self didSelectContact:contactUser];
}

@end
