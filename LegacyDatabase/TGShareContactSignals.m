#import "TGShareContactSignals.h"

#import "ApiLayer70.h"
#import "TGUploadedMessageContentMedia.h"

@implementation TGShareContactSignals

+ (SSignal *)contactMessageContentForContact:(TGContactModel *)contact parentController:(UIViewController *)parentController
{
    SSignal *(^contentSignal)(TGPhoneNumberModel *) = ^SSignal *(TGPhoneNumberModel *phone)
    {
        Api70_InputMedia_inputMediaContact *inputContact = [Api70_InputMedia inputMediaContactWithPhoneNumber:phone.phoneNumber firstName:contact.firstName.length == 0 ? @"" : contact.firstName lastName:contact.lastName.length == 0 ? @"" : contact.lastName];
        
        return [SSignal single:[[TGUploadedMessageContentMedia alloc] initWithInputMedia:inputContact]];
    };
    
    if (contact.phoneNumbers.count == 1)
    {
        return contentSignal(contact.phoneNumbers.firstObject);
    }
    else
    {
        return [[[self selectPhoneNumberSignal:contact parentController:parentController] startOn:[SQueue mainQueue]] mapToSignal:^SSignal *(TGPhoneNumberModel *phone)
        {
            return contentSignal(phone);
        }];
    }
}

+ (SSignal *)selectPhoneNumberSignal:(TGContactModel *)contact parentController:(UIViewController *)parentController
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        NSMutableArray *nameParts = [[NSMutableArray alloc] init];
        if (contact.firstName.length > 0)
            [nameParts addObject:contact.firstName];
        if (contact.lastName.length > 0)
            [nameParts addObject:contact.lastName];
        
        NSString *name = [nameParts componentsJoinedByString:@" "];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:name message:NSLocalizedString(@"Share.ChoosePhoneNumber", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        for (TGPhoneNumberModel *number in contact.phoneNumbers)
        {
            NSString *title = number.label.length == 0 ? number.displayPhoneNumber : [[NSString alloc] initWithFormat:@"%@: %@", number.label, number.displayPhoneNumber];
            [alertController addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
            {
                [subscriber putNext:number];
                [subscriber putCompletion];
            }]];
        }
        
        [parentController presentViewController:alertController animated:true completion:nil];

        return nil;
    }];
}

@end
