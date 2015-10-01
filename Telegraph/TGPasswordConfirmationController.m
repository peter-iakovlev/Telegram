#import "TGPasswordConfirmationController.h"

#import "TGTwoStepConfigSignal.h"

#import "TGCommentCollectionItem.h"

@interface TGPasswordConfirmationController ()
{
    SMetaDisposable *_twoStepConfigDisposable;
}

@end

@implementation TGPasswordConfirmationController

- (instancetype)initWithEmail:(NSString *)email
{
    self = [super init];
    if (self != nil)
    {
        _twoStepConfigDisposable = [[SMetaDisposable alloc] init];
        
        self.title = TGLocalized(@"TwoStepAuth.ConfirmationTitle");
        
        __weak TGPasswordConfirmationController *weakSelf = self;
        
        TGCommentCollectionItem *textItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"TwoStepAuth.ConfirmationText")];
        TGCommentCollectionItem *emailItem = [[TGCommentCollectionItem alloc] initWithText:email];
        emailItem.topInset = 4.0f;
        TGCommentCollectionItem *changeItem = [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"TwoStepAuth.ConfirmationChangeEmail")];
        changeItem.topInset = -6.0f;
        changeItem.textColor = TGAccentColor();
        changeItem.action = ^
        {
            __strong TGPasswordConfirmationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (strongSelf->_changeEmail)
                    strongSelf->_changeEmail();
            }
        };
        TGCommentCollectionItem *abortItem = [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"TwoStepAuth.ConfirmationAbort")];
        abortItem.topInset = 0.0f;
        abortItem.textColor = TGAccentColor();
        abortItem.action = ^
        {
            __strong TGPasswordConfirmationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (strongSelf->_removePassword)
                    strongSelf->_removePassword();
            }
        };
        
        TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:@[
            textItem,
            emailItem,
            //changeItem,
            abortItem
        ]];
        section.insets = UIEdgeInsetsMake(16.0f, 0.0f, 32.0f, 0.0f);
        [self.menuSections addSection:section];
        
        [self updateConfig];
    }
    return self;
}

- (void)dealloc
{
    [_twoStepConfigDisposable dispose];
}

- (void)updateConfig
{
    __weak TGPasswordConfirmationController *weakSelf = self;
    [_twoStepConfigDisposable setDisposable:[[[[TGTwoStepConfigSignal twoStepConfig] delay:5.0 onQueue:[SQueue concurrentDefaultQueue]] deliverOn:[SQueue mainQueue]] startWithNext:^(TGTwoStepConfig *config)
    {
        __strong TGPasswordConfirmationController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (config.currentSalt.length != 0)
            {
                if (strongSelf->_completion)
                    strongSelf->_completion();
            }
            else
                [strongSelf updateConfig];
        }
    }]];
}

@end
