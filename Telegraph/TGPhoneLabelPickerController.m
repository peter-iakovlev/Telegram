/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPhoneLabelPickerController.h"

#import "TGSynchronizeContactsActor.h"

#import "TGRegularCheckCollectionItem.h"

@interface TGPhoneLabelPickerController ()

@end

@implementation TGPhoneLabelPickerController

- (instancetype)initWithSelectedLabel:(NSString *)selectedLabel
{
    self = [super init];
    if (self != nil)
    {
        [self setTitleText:TGLocalized(@"PhoneLabel.Title")];
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
        
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
        
        NSMutableArray *mainSectionItems = [[NSMutableArray alloc] init];
        
        bool foundLabel = false;
        for (NSString *label in [TGSynchronizeContactsManager phoneLabels])
        {
            bool isChecked = false;
            
            if ([label isEqualToString:selectedLabel])
            {
                foundLabel = true;
                isChecked = true;
            }
            
            TGRegularCheckCollectionItem *checkItem = [[TGRegularCheckCollectionItem alloc] initWithTitle:label action:@selector(labelPressed:)];
            checkItem.isChecked = isChecked;
            [mainSectionItems addObject:checkItem];
        }
        
        TGCollectionMenuSection *mainSection = [[TGCollectionMenuSection alloc] initWithItems:mainSectionItems];
        UIEdgeInsets topSectionInsets = mainSection.insets;
        topSectionInsets.top = 36.0f;
        mainSection.insets = topSectionInsets;
        [self.menuSections addSection:mainSection];
        
        if (!foundLabel)
        {
            TGRegularCheckCollectionItem *checkItem = [[TGRegularCheckCollectionItem alloc] initWithTitle:selectedLabel action:@selector(labelPressed:)];
            checkItem.isChecked = true;
            
            TGCollectionMenuSection *additionalSection = [[TGCollectionMenuSection alloc] initWithItems:@[
                checkItem
            ]];
            [self.menuSections addSection:additionalSection];
        }
    }
    return self;
}

- (void)cancelPressed
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)donePressed
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)labelPressed:(TGRegularCheckCollectionItem *)item
{
    id<TGPhoneLabelPickerControllerDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(phoneLabelPickerController:didFinishWithLabel:)])
        [delegate phoneLabelPickerController:self didFinishWithLabel:item.title];
    
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

@end
