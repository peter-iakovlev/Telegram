#import "TGUserAboutSetupController.h"

#import "TGConversation.h"
#import "TGAccountSignals.h"

#import "TGCollectionMultilineInputItem.h"
#import "TGCommentCollectionItem.h"

#import "TGProgressWindow.h"
#import "TGAlertView.h"

#import "TGDatabase.h"

#import "TGTelegraph.h"

#import "TGUserSignal.h"
#import "TGAccountSignals.h"

@interface TGUserAboutSetupController () {
    id<SDisposable> _updatedCachedDataDisposable;
    id<SDisposable> _currentAboutDisposable;
    SMetaDisposable *_updateAboutDisposable;
    
    TGCollectionMenuSection *_aboutSection;
    TGCollectionMultilineInputItem *_inputItem;
}

@end

@implementation TGUserAboutSetupController

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _updateAboutDisposable = [[SMetaDisposable alloc] init];
        
        self.title = TGLocalized(@"Settings.About.Title");
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
        
        _inputItem = [[TGCollectionMultilineInputItem alloc] init];
        _inputItem.maxLength = 200;
        _inputItem.placeholder = TGLocalized(@"Channel.About.Placeholder");
        __weak TGUserAboutSetupController *weakSelf = self;
        _inputItem.heightChanged = ^ {
            __strong TGUserAboutSetupController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf.collectionLayout invalidateLayout];
                [strongSelf.collectionView layoutSubviews];
            }
        };
        
        TGCommentCollectionItem *commentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Settings.About.Help")];
        commentItem.topInset = 1.0f;
        
        _aboutSection = [[TGCollectionMenuSection alloc] initWithItems:@[_inputItem, commentItem]];
        _aboutSection.insets = UIEdgeInsetsMake(35.0f, 0.0f, 0.0f, 0.0f);
        [self.menuSections addSection:_aboutSection];
        
        _updatedCachedDataDisposable = [[TGUserSignal updatedUserCachedDataWithUserId:TGTelegraphInstance.clientUserId] startWithNext:nil];
        
        _currentAboutDisposable = [[[[TGDatabaseInstance() userCachedData:TGTelegraphInstance.clientUserId] take:1] deliverOn:[SQueue mainQueue]] startWithNext:^(TGCachedUserData *data) {
            __strong TGUserAboutSetupController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf->_inputItem setText:data.about];
            }
        }];
    }
    return self;
}

- (void)dealloc {
    [_updateAboutDisposable dispose];
    [_currentAboutDisposable dispose];
}

- (BOOL)shouldAutorotate
{
    return true;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_inputItem becomeFirstResponder];
}

- (void)cancelPressed
{
    [self.view endEditing:true];
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)donePressed {
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow show:true];
    
    __weak TGUserAboutSetupController *weakSelf = self;
    
    [_updateAboutDisposable setDisposable:[[[[TGAccountSignals updateAbout:_inputItem.text] deliverOn:[SQueue mainQueue]] onDispose:^{
        [progressWindow dismiss:true];
    }] startWithNext:nil error:^(__unused id error) {
        [[[TGAlertView alloc] initWithTitle:TGLocalized(@"Channel.About.Error") message:nil cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
    } completed:^{
        __strong TGUserAboutSetupController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf.view endEditing:true];
            [strongSelf.presentingViewController dismissViewControllerAnimated:true completion:nil];
        }
    }]];
}

- (void)_resetCollectionView {
    [super _resetCollectionView];
    
    if (iosMajorVersion() >= 7) {
        self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
}

@end
