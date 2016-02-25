#import "TGReportPeerOtherTextController.h"

#import "TGCollectionMultilineInputItem.h"

@interface TGReportPeerOtherTextController () {
    void (^_completion)(NSString *);
    
    TGCollectionMenuSection *_aboutSection;
    TGCollectionMultilineInputItem *_inputItem;
    
    UIBarButtonItem *_doneItem;
}

@end

@implementation TGReportPeerOtherTextController

- (instancetype)initWithCompletion:(void (^)(NSString *))completion {
    self = [super init];
    if (self != nil) {
        _completion = [completion copy];
        
        self.title = TGLocalized(@"ReportPeer.ReasonOther.Title");
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        _doneItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"ReportPeer.ReasonOther.Send") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
        [self setRightBarButtonItem:_doneItem];
        _doneItem.enabled = false;
        
        _inputItem = [[TGCollectionMultilineInputItem alloc] init];
        _inputItem.maxLength = 200;
        _inputItem.placeholder = TGLocalized(@"ReportPeer.ReasonOther.Placeholder");
        __weak TGReportPeerOtherTextController *weakSelf = self;
        _inputItem.heightChanged = ^ {
            __strong TGReportPeerOtherTextController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf.collectionLayout invalidateLayout];
                [strongSelf.collectionView layoutSubviews];
            }
        };
        _inputItem.textChanged = ^(NSString *text) {
            __strong TGReportPeerOtherTextController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                strongSelf->_doneItem.enabled = text.length != 0;
            }
        };
        
        /*TGCommentCollectionItem *commentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:_conversation.isChannelGroup ? TGLocalized(@"Group.About.Help") : TGLocalized(@"Channel.About.Help")];
        commentItem.topInset = 1.0f;*/
        
        _aboutSection = [[TGCollectionMenuSection alloc] initWithItems:@[_inputItem]];
        _aboutSection.insets = UIEdgeInsetsMake(35.0f, 0.0f, 0.0f, 0.0f);
        [self.menuSections addSection:_aboutSection];
    }
    return self;
}

- (void)cancelPressed {
    [self.view endEditing:true];
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)donePressed {
    [self.view endEditing:true];
    NSString *text = _inputItem.text;
    if (_completion) {
        _completion(text);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_inputItem becomeFirstResponder];
}

@end
