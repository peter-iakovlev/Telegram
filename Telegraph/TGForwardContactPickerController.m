/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGForwardContactPickerController.h"

#import "TGDatabase.h"

#import "TGActionSheet.h"

#import "TGStringUtils.h"

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
    [self deselectRow];
    
    TGPhonebookContact *contact = nil;
    
    if (user.uid < 0)
        contact = [TGDatabaseInstance() phonebookContactByNativeId:-user.uid];
    else
        contact = [TGDatabaseInstance() phonebookContactByPhoneId:phoneMatchHash(user.phoneNumber)];
    
    if (contact != nil && contact.phoneNumbers.count != 0)
    {
        if (contact.phoneNumbers.count == 1)
        {
            TGUser *contactUser = [user copy];
            contactUser.phoneNumber = ((TGPhoneNumber *)contact.phoneNumbers[0]).number;
            
            [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
            
            id<TGForwardContactPickerControllerDelegate> delegate = _delegate;
            if ([delegate respondsToSelector:@selector(forwardContactPickerController:didSelectContact:)])
                [delegate forwardContactPickerController:self didSelectContact:contactUser];
        }
        else
        {
            NSMutableArray *actions = [[NSMutableArray alloc] init];
            for (TGPhoneNumber *number in contact.phoneNumbers)
            {
                if (number.number.length != 0)
                {
                    NSString *title = number.label.length == 0 ? number.number : [[NSString alloc] initWithFormat:@"%@: %@", number.label, number.number];
                    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:title action:number.number]];
                }
            }
            
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
            
            __weak TGForwardContactPickerController *weakSelf = self;
            [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(__unused id target, NSString *action)
            {
                TGForwardContactPickerController *strongSelf = weakSelf;
                if (![action isEqualToString:@"cancel"])
                {
                    TGUser *contactUser = [[TGUser alloc] init];
                    contactUser.firstName = contact.firstName;
                    contactUser.lastName = contact.lastName;
                    contactUser.phoneNumber = action;
                    
                    if (phoneMatchHash(contactUser.phoneNumber) == phoneMatchHash(user.phoneNumber))
                        contactUser.uid = user.uid;
                    
                    void (^finishBlock)(void) = ^
                    {
                        [strongSelf.presentingViewController dismissViewControllerAnimated:true completion:nil];
                        
                        id<TGForwardContactPickerControllerDelegate> delegate = strongSelf.delegate;
                        if ([delegate respondsToSelector:@selector(forwardContactPickerController:didSelectContact:)])
                            [delegate forwardContactPickerController:self didSelectContact:contactUser];
                    };
                    
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                        dispatch_async(dispatch_get_main_queue(), finishBlock);
                    else
                        finishBlock();
                }
            } target:self] showInView:self.view];
        }
    }
}

@end
