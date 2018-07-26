#import "TGShareContactSignals.h"

#import "ApiLayer82.h"
#import "TGUploadedMessageContentMedia.h"
#import "TGShareContactController.h"
#import "TGVCard.h"

@implementation TGShareContactSignals

+ (SSignal *)contactMessageContentForContact:(TGContactModel *)contact parentController:(UIViewController *)parentController context:(TGShareContext *)context
{
    TGUploadedMessageContentMedia *(^content)(TGContactModel *) = ^TGUploadedMessageContentMedia *(TGContactModel *contact)
    {
        TGPhoneNumberModel *phoneNumber = contact.phoneNumbers.firstObject;
        Api82_InputMedia_inputMediaContact *inputContact = [Api82_InputMedia inputMediaContactWithPhoneNumber:phoneNumber.phoneNumber firstName:contact.firstName.length == 0 ? @"" : contact.firstName lastName:contact.lastName.length == 0 ? @"" : contact.lastName vcard:contact.vcard.vcardString];
        
        return [[TGUploadedMessageContentMedia alloc] initWithInputMedia:inputContact];
    };
    
    if (contact.vcard.isPrimitive) {
        return [SSignal single:content(contact)];
    } else {
        return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
        {
            TGShareContactController *controller = [[TGShareContactController alloc] initWithContext:context vCard:contact.vcard uid:0];
            controller.completionBlock = ^(TGContactModel *contact)
            {
                [subscriber putNext:content(contact)];
                [subscriber putCompletion];
            };
            UINavigationController *navController = [parentController isKindOfClass:[UINavigationController class]] ? (UINavigationController *)parentController : parentController.navigationController;
            [navController pushViewController:controller animated:true];
            
            return nil;
        }] startOn:[SQueue mainQueue]];
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
