#import "TGChannelAboutSetupController.h"

#import "TGConversation.h"
#import "TGChannelManagementSignals.h"

#import "TGCollectionMultilineInputItem.h"
#import "TGCommentCollectionItem.h"

#import "TGProgressWindow.h"
#import "TGAlertView.h"

@interface TGChannelAboutSetupController () {
    TGConversation *_conversation;
    SMetaDisposable *_updateAboutDisposable;
    
    TGCollectionMenuSection *_aboutSection;
    TGCollectionMultilineInputItem *_inputItem;
    
    void (^_block)(NSString *);
}

@end

@implementation TGChannelAboutSetupController

- (instancetype)initWithConversation:(TGConversation *)conversation {
    self = [super init];
    if (self != nil) {
        _conversation = conversation;
        [self commonInit:conversation.about];
    }
    return self;
}

- (instancetype)initWithBlock:(void (^)(NSString *about))block text:(NSString *)text {
    self = [super init];
    if (self != nil) {
        _block = [block copy];
        [self commonInit:text];
    }
    return self;
}

- (void)commonInit:(NSString *)text {
    _updateAboutDisposable = [[SMetaDisposable alloc] init];
    
    self.title = TGLocalized(@"Channel.About.Title");
    [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
    
    _inputItem = [[TGCollectionMultilineInputItem alloc] init];
    _inputItem.maxLength = 200;
    _inputItem.text = text;
    _inputItem.placeholder = TGLocalized(@"Channel.About.Placeholder");
    __weak TGChannelAboutSetupController *weakSelf = self;
    _inputItem.heightChanged = ^ {
        __strong TGChannelAboutSetupController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf.collectionLayout invalidateLayout];
            [strongSelf.collectionView layoutSubviews];
        }
    };
    
    TGCommentCollectionItem *commentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Channel.About.Help")];
    commentItem.topInset = 1.0f;
    
    _aboutSection = [[TGCollectionMenuSection alloc] initWithItems:@[_inputItem, commentItem]];
    _aboutSection.insets = UIEdgeInsetsMake(35.0f, 0.0f, 0.0f, 0.0f);
    [self.menuSections addSection:_aboutSection];
}

- (void)dealloc {
    [_updateAboutDisposable dispose];
}

- (BOOL)shouldAutorotate
{
    return true;
}

- (void)cancelPressed
{
    [self.view endEditing:true];
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)donePressed {
    if (TGStringCompare(_conversation.about, _inputItem.text)) {
        [self.view endEditing:true];
        [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
    } else {
        if (_block != nil) {
            [self.view endEditing:true];
            [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
            _block(_inputItem.text);
        } else {
            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
            [progressWindow show:true];
            
            __weak TGChannelAboutSetupController *weakSelf = self;
            [_updateAboutDisposable setDisposable:[[[[TGChannelManagementSignals updateChannelAbout:_conversation.conversationId accessHash:_conversation.accessHash about:_inputItem.text] deliverOn:[SQueue mainQueue]] onDispose:^{
                [progressWindow dismiss:true];
            }] startWithNext:nil error:^(__unused id error) {
                [[[TGAlertView alloc] initWithTitle:TGLocalized(@"Channel.About.Error") message:nil cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
            } completed:^{
                __strong TGChannelAboutSetupController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf.view endEditing:true];
                    [strongSelf.presentingViewController dismissViewControllerAnimated:true completion:nil];
                }
            }]];
        }
    }
}

- (void)_resetCollectionView {
    [super _resetCollectionView];
    
    if (iosMajorVersion() >= 7) {
        self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
}

@end
