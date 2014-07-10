/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGAddToExistingContactController.h"

#import "TGCreateContactController.h"

@interface TGAddToExistingContactController () <TGCreateContactControllerDelegate>
{
    int32_t _uid;
    NSString *_phoneNumber;
}

@end

@implementation TGAddToExistingContactController

- (id)initWithUid:(int32_t)uid phoneNumber:(NSString *)phoneNumber
{
    self = [super initWithContactsMode:TGContactsModeRegistered | TGContactsModePhonebook | TGContactsModeSelectModal];
    if (self != nil)
    {
        _uid = uid;
        _phoneNumber = phoneNumber;
        
        self.titleText = TGLocalized(@"Contacts.Title");
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
    if (user.uid > 0)
    {
        TGCreateContactController *createContactController = [[TGCreateContactController alloc] initWithUid:_uid phoneNumber:_phoneNumber existingUid:user.uid];
        createContactController.delegate = self;
        [self.navigationController pushViewController:createContactController animated:true];
    }
    else
    {
        TGCreateContactController *createContactController = [[TGCreateContactController alloc] initWithUid:_uid phoneNumber:_phoneNumber existingNativeContactId:-user.uid];
        createContactController.delegate = self;
        [self.navigationController pushViewController:createContactController animated:true];
    }
}

- (void)createContactControllerDidFinish:(TGCreateContactController *)__unused createContactController
{
    id<TGAddToExistingContactControllerDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(addToExistingContactControllerDidFinish:)])
        [delegate addToExistingContactControllerDidFinish:self];
    else
        [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

@end
