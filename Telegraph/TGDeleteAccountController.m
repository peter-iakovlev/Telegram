#import "TGDeleteAccountController.h"

#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGTextViewCollectionItem.h"

#import "TGProgressWindow.h"

@interface TGDeleteAccountController ()
{
    TGProgressWindow *_progressWindow;
    
    TGTextViewCollectionItem *_reasonTextItem;
    TGButtonCollectionItem *_deleteAccountButton;
}

@end

@implementation TGDeleteAccountController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.title = TGLocalized(@"DeleteAccount.Title");
        
        _deleteAccountButton = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"DeleteAccount.DeleteAccount") action:@selector(deleteAccountPressed)];
        _deleteAccountButton.titleColor = TGDestructiveAccentColor();
        _deleteAccountButton.enabled = false;
        _deleteAccountButton.deselectAutomatically = true;
        
        __weak TGDeleteAccountController *weakSelf = self;
        _reasonTextItem = [[TGTextViewCollectionItem alloc] initWithNumberOfLines:4];
        _reasonTextItem.textChanged = ^(NSString *text)
        {
            __strong TGDeleteAccountController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_deleteAccountButton.enabled = text.length != 0;
            }
        };
        
        TGCollectionMenuSection *mainSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"DeleteAccount.Help")],
            _reasonTextItem,
        ]];
        UIEdgeInsets topSectionInsets = mainSection.insets;
        topSectionInsets.top = 16.0f;
        mainSection.insets = topSectionInsets;
        [self.menuSections addSection:mainSection];
        
        TGCollectionMenuSection *actionSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _deleteAccountButton
        ]];
        [self.menuSections addSection:actionSection];
    }
    return self;
}

- (void)deleteAccountPressed
{
    
}

@end
