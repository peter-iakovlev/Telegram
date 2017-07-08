#import "TGSuggestedLocalizationController.h"

#import "TGSuggestedLocalizationControllerView.h"

@interface TGSuggestedLocalizationController () {
    TGSuggestedLocalization *_suggestedLocalization;
    TGSuggestedLocalizationControllerView *_controllerView;
    bool _hasAppeared;
}

@end

@implementation TGSuggestedLocalizationController

- (instancetype)initWithSuggestedLocalization:(TGSuggestedLocalization *)suggestedLocalization {
    self = [super init];
    if (self != nil) {
        _suggestedLocalization = suggestedLocalization;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.view.opaque = false;
    self.view.backgroundColor = nil;
    
    __weak TGSuggestedLocalizationController *weakSelf = self;
    
    _controllerView = [[TGSuggestedLocalizationControllerView alloc] initWithSuggestedLocalization:_suggestedLocalization];
    _controllerView.frame = self.view.bounds;
    _controllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_controllerView];
    
    _controllerView.dismiss = ^{
        __strong TGSuggestedLocalizationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf dismissAnimated];
        }
    };
    
    _controllerView.appliedLanguage = ^{
        __strong TGSuggestedLocalizationController *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_appliedLanguage) {
            strongSelf->_appliedLanguage();
        }
    };
    
    _controllerView.other = ^{
        __strong TGSuggestedLocalizationController *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_other) {
            strongSelf->_other();
        }
    };
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_hasAppeared) {
        _hasAppeared = true;
        [_controllerView animateIn];
    }
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    if ([self isViewLoaded]) {
        _controllerView.insets = self.controllerInset;
        [_controllerView setNeedsLayout];
        [_controllerView layoutSubviews];
    }
}

- (void)dismissAnimated {
    __weak TGSuggestedLocalizationController *weakSelf = self;
    [_controllerView animateOut:^{
        __strong TGSuggestedLocalizationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf.presentingViewController dismissViewControllerAnimated:false completion:nil];
        }
    }];
}

@end
