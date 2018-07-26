#import "TGGDPRNoticeController.h"

#import <SafariServices/SafariServices.h>

#import <LegacyComponents/TGFont.h>
#import <LegacyComponents/TGModernButton.h>
#import <LegacyComponents/TGMediaPickerToolbarView.h>

#import <LegacyComponents/TGMessage.h>

#import "TGApplication.h"
#import "TGAppDelegate.h"
#import "TGTelegraph.h"
#import "TGDatabase.h"
#import "TGPresentation.h"
#import <LegacyComponents/TGPhoneUtils.h>

#import "TGTermsOfService.h"
#import "TGAccountSignals.h"

#import "TGCollectionStaticMultilineTextItemView.h"
#import "TGModernTextViewModel.h"
#import "TGReusableLabel.h"

#import "TGOpenInMenu.h"

#import "TGCustomAlertView.h"
#import "TGCustomActionSheet.h"

@interface TGGDPRNoticeController ()
{
    TGTermsOfService *_termsOfService;
    
    UIView *_headerView;
    UIView *_headerSeparator;
    UILabel *_headerLabel;
    
    UIView *_backgroundView;
    UIView *_topSeparator;
    UIView *_bottomSeparator;
    
    UIScrollView *_scrollView;
    TGCollectionStaticMultilineTextItemViewTextView *_textView;
    TGModernTextViewModel *_textModel;
    
    TGMediaPickerToolbarView *_toolbarView;
}
@end

@implementation TGGDPRNoticeController

- (instancetype)initWithTermsOfService:(TGTermsOfService *)termsOfService
{
    self = [super init];
    if (self != nil)
    {
        self.title = TGLocalized(@"PrivacyPolicy.Title");
        _termsOfService = termsOfService;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = _presentation.pallete.collectionMenuBackgroundColor;
    
    _scrollView = [[UIScrollView alloc] init];
    if (iosMajorVersion() >= 11)
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _scrollView.alwaysBounceVertical = true;
    [self.view addSubview:_scrollView];
    
    _backgroundView = [[UIView alloc] init];
    _backgroundView.backgroundColor = _presentation.pallete.collectionMenuCellBackgroundColor;
    [_scrollView addSubview:_backgroundView];
    
    _topSeparator = [[UIView alloc] init];
    _topSeparator.backgroundColor = _presentation.pallete.collectionMenuSeparatorColor;
    [_backgroundView addSubview:_topSeparator];
    
    _bottomSeparator = [[UIView alloc] init];
    _bottomSeparator.backgroundColor = _presentation.pallete.collectionMenuSeparatorColor;
    [_backgroundView addSubview:_bottomSeparator];
    
    _textView = [[TGCollectionStaticMultilineTextItemViewTextView alloc] init];
    _textView.userInteractionEnabled = true;

    __weak TGGDPRNoticeController *weakSelf = self;
    _textView.followLink = ^(NSString *url)
    {
        __strong TGGDPRNoticeController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf openLink:url];
    };
    _textView.holdLink = ^(NSString *url)
    {
        __strong TGGDPRNoticeController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf showActionsMenuForLink:url];
    };
    [_backgroundView addSubview:_textView];
    
    UIEdgeInsets inset = [TGViewController safeAreaInsetForOrientation:self.interfaceOrientation];
    _toolbarView = [[TGMediaPickerToolbarView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - TGMediaPickerToolbarHeight - inset.bottom, self.view.frame.size.width, TGMediaPickerToolbarHeight + inset.bottom)];
    _toolbarView.safeAreaInset = [TGViewController safeAreaInsetForOrientation:self.interfaceOrientation];
    _toolbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _toolbarView.leftButtonTitle = TGLocalized(@"PrivacyPolicy.Decline");
    _toolbarView.rightButtonTitle = TGLocalized(@"PrivacyPolicy.Accept");
    [_toolbarView setRightButtonEnabled:true animated:false];
    
    self.explicitTableInset = UIEdgeInsetsMake(0.0f, 0.0f, TGMediaPickerToolbarHeight, 0.0f);
    self.explicitScrollIndicatorInset = self.explicitTableInset;
    
    _toolbarView.leftPressed = ^
    {
        __strong TGGDPRNoticeController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf declineButtonPressed];
    };
    _toolbarView.rightPressed = ^
    {
        __strong TGGDPRNoticeController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf acceptButtonPressed];
    };
    [_toolbarView setPallete:_presentation.mediaAssetsPallete];
    [self.view addSubview:_toolbarView];
    
    NSMutableArray *entities = [[NSMutableArray alloc] init];
    for (TGMessageEntity *entity in _termsOfService.entities)
    {
        if (![entity isKindOfClass:[TGMessageEntityMention class]])
            [entities addObject:entity];
    }
    
    [self setupText:_termsOfService.text textCheckingResults:[TGMessage textCheckingResultsForText:_termsOfService.text highlightMentionsAndTags:false highlightCommands:false entities:entities]];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _presentation = presentation;
    
    self.view.backgroundColor = presentation.pallete.collectionMenuBackgroundColor;
    
    _headerView.backgroundColor = presentation.pallete.barBackgroundColor;
    _headerSeparator.backgroundColor = presentation.pallete.barSeparatorColor;
    _headerLabel.textColor = presentation.pallete.navigationTitleColor;
    
    _backgroundView.backgroundColor = presentation.pallete.collectionMenuCellBackgroundColor;
    _topSeparator.backgroundColor = presentation.pallete.collectionMenuSeparatorColor;
    _bottomSeparator.backgroundColor = presentation.pallete.collectionMenuSeparatorColor;
    
    [_toolbarView setPallete:presentation.mediaAssetsPallete];
}

- (void)setupText:(NSString *)text textCheckingResults:(NSArray *)textCheckingResults
{
    _textModel = [[TGModernTextViewModel alloc] initWithText:text font:TGCoreTextSystemFontOfSize(16.0f)];
    _textModel.textColor = self.presentation.pallete.textColor;
    _textModel.linkColor = self.presentation.pallete.accentColor;
    _textModel.underlineAllLinks = self.presentation.pallete.underlineAllOutgoingLinks;
    _textModel.textCheckingResults = textCheckingResults;
    _textModel.layoutFlags = TGReusableLabelLayoutMultiline | TGReusableLabelLayoutHighlightLinks;
    
    UIEdgeInsets safeAreaInset = [TGViewController safeAreaInsetForOrientation:self.interfaceOrientation];
    CGFloat parentWidth = self.view.frame.size.width - safeAreaInset.left - safeAreaInset.right;
    [_textModel layoutForContainerSize:CGSizeMake([self textWidthForWidth:parentWidth], CGFLOAT_MAX)];
    
    [_textView setTextModel:_textModel];
    [self.view setNeedsLayout];
}

- (void)openLink:(NSString *)url
{
    if ([url hasPrefix:@"mention://"])
    {
        //NSString *displayString = [@"@" stringByAppendingString:[url substringFromIndex:@"mention://".length]];
    }
    else
    {
        [TGAppDelegateInstance handleOpenInstantView:url disableActions:true];
    }
}

- (void)showActionsMenuForLink:(NSString *)url
{
    if (url.length == 0)
        return;

    UIView *parentView = self.view;

    NSString *displayString = url;
    if ([url hasPrefix:@"hashtag://"])
        displayString = [@"#" stringByAppendingString:[url substringFromIndex:@"hashtag://".length]];
    else if ([url hasPrefix:@"mention://"])
        displayString = [@"@" stringByAppendingString:[url substringFromIndex:@"mention://".length]];
    
    NSURL *link = [NSURL URLWithString:url];
    if (link.scheme.length == 0)
        link = [NSURL URLWithString:[@"http://" stringByAppendingString:url]];
    
    bool useOpenIn = false;
    bool isWeblink = false;
    if ([link.scheme isEqualToString:@"http"] || [link.scheme isEqualToString:@"https"])
    {
        isWeblink = true;
        if ([TGOpenInMenu hasThirdPartyAppsForURL:link])
            useOpenIn = true;
    }
    
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    if (useOpenIn)
    {
        TGActionSheetAction *openInAction = [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.FileOpenIn") action:@"openIn"];
        openInAction.disableAutomaticSheetDismiss = true;
        [actions addObject:openInAction];
    }
    else
    {
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.LinkDialogOpen") action:@"open"]];
    }
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.LinkDialogCopy") action:@"copy"]];
    
    if (isWeblink && iosMajorVersion() >= 7)
    {
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.AddToReadingList") action:@"addToReadingList"]];
    }
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    TGCustomActionSheet *actionSheet = [[TGCustomActionSheet alloc] initWithTitle:displayString.length < 70 ? displayString : [[displayString substringToIndex:70] stringByAppendingString:@"..."] actions:actions menuController:nil advancedActionBlock:^(TGMenuSheetController *menuController, TGGDPRNoticeController *controller, NSString *action)
    {
        if ([action isEqualToString:@"open"])
        {
            [controller openLink:url];
        }
        else if ([action isEqualToString:@"openIn"])
        {
            [TGOpenInMenu presentInParentController:controller menuController:menuController title:TGLocalized(@"Map.OpenIn") url:link buttonTitle:nil buttonAction:nil sourceView:parentView sourceRect:nil barButtonItem:nil];
        }
        else if ([action isEqualToString:@"copy"])
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            if (pasteboard != nil)
            {
                NSString *copyString = url;
                if ([url hasPrefix:@"mailto:"])
                    copyString = [url substringFromIndex:7];
                else if ([url hasPrefix:@"tel:"])
                    copyString = [url substringFromIndex:4];
                else if ([url hasPrefix:@"hashtag://"])
                    copyString = [@"#" stringByAppendingString:[url substringFromIndex:@"hashtag://".length]];
                else if ([url hasPrefix:@"mention://"])
                    copyString = [@"@" stringByAppendingString:[url substringFromIndex:@"mention://".length]];
                [pasteboard setString:copyString];
            }
        }
        else if ([action isEqualToString:@"addToReadingList"])
        {
            [[SSReadingList defaultReadingList] addReadingListItemWithURL:[NSURL URLWithString:url] title:url previewText:nil error:NULL];
        }
    } target:self];
    [actionSheet showInView:parentView];
}

- (void)acceptButtonPressed
{
    __weak TGGDPRNoticeController *weakSelf = self;
    void (^acceptBlock)(void) = ^
    {
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [progressWindow showWithDelay:0.2];
        
        [[[TGAccountSignals acceptTermsOfService:_termsOfService.identifier] deliverOn:[SQueue mainQueue]] startWithNext:nil completed:^
        {
            [progressWindow dismiss:true];
            
            __strong TGGDPRNoticeController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
        }];
    };
    if (_termsOfService.minimumAgeRequired != nil)
    {
        [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"PrivacyPolicy.AgeVerificationTitle") message:[NSString stringWithFormat:TGLocalized(@"PrivacyPolicy.AgeVerificationMessage"), [NSString stringWithFormat:@"%d", [_termsOfService.minimumAgeRequired intValue]]] cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"PrivacyPolicy.AgeVerificationAgree") completionBlock:^(bool okButtonPressed)
        {
            if (okButtonPressed)
            {
                acceptBlock();
            }
        }];
    }
    else
    {
        acceptBlock();
    }
}

- (void)declineButtonPressed
{
    [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"PrivacyPolicy.DeclineTitle") message:TGLocalized(@"PrivacyPolicy.DeclineMessage") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"PrivacyPolicy.DeclineDeclineAndDelete") destructive:false completionBlock:^(bool okButtonPressed)
    {
        if (okButtonPressed)
            [self displayLastWarning];
    } disableKeyboardWorkaround:false];
}


- (void)displayLastWarning
{
    [TGCustomAlertView presentAlertWithTitle:nil message:TGLocalized(@"PrivacyPolicy.DeclineLastWarning") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"PrivacyPolicy.DeclineDeleteNow") destructive:true completionBlock:^(bool okButtonPressed)
     {
         if (okButtonPressed)
             [self performDelete];
     } disableKeyboardWorkaround:false];
}

- (void)performDelete
{
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:true];
    
    __weak TGGDPRNoticeController *weakSelf = self;
    [[[TGAccountSignals deleteAccount:@"Decline ToS"] deliverOn:[SQueue mainQueue]] startWithNext:nil error:^(__unused id error)
    {
    } completed:^
    {
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [TGTelegraphInstance doLogout:nil soft:true];
        
        TGDispatchAfter(0.2, dispatch_get_main_queue(), ^
        {
            [progressWindow dismiss:true];
                            
            __strong TGGDPRNoticeController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
        });
    });
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    if (self.view.frame.size.width > self.view.frame.size.height)
        orientation = UIInterfaceOrientationLandscapeLeft;
    UIEdgeInsets safeAreaInset = [TGViewController safeAreaInsetForOrientation:orientation];
    safeAreaInset.top = 20.0f;
    
    _headerView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f + safeAreaInset.top);
    _headerLabel.frame = CGRectMake(CGFloor((self.view.frame.size.width - _headerLabel.frame.size.width) / 2.0f), safeAreaInset.top + (44.0f - _headerLabel.frame.size.height) / 2.0f, _headerLabel.frame.size.width, _headerLabel.frame.size.height);
    _headerSeparator.frame = CGRectMake(0.0f, _headerView.frame.size.height, self.view.frame.size.width, TGScreenPixel);
    
    CGFloat parentWidth = self.view.frame.size.width - safeAreaInset.left - safeAreaInset.right;
    CGFloat captionWidth = 0.0f;
    if (_textModel.text.length > 0)
    {
        captionWidth = [self textWidthForWidth:parentWidth];
        if ([_textModel layoutNeedsUpdatingForContainerSize:CGSizeMake(captionWidth, CGFLOAT_MAX)])
            [_textModel layoutForContainerSize:CGSizeMake(captionWidth, CGFLOAT_MAX)];
        
        CGSize targetSize = CGSizeMake(captionWidth, [self textHeightForWidth:captionWidth]);
        if (fabs(targetSize.width - _textView.frame.size.width) > FLT_EPSILON || fabs(targetSize.height - _textView.frame.size.height) > FLT_EPSILON)
        {
            _textView.frame = CGRectMake(16.0f + safeAreaInset.left, 16.0f, targetSize.width, targetSize.height);
            [_textView setNeedsDisplay];
        }
    }
    
    _backgroundView.frame = CGRectMake(0.0f, 35.0f, self.view.frame.size.width, _textView.frame.size.height + 16.0f + 16.0f);
    _scrollView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _backgroundView.frame.size.height + 2.0f * 35.0f);
    
    _topSeparator.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, TGScreenPixel);
    _bottomSeparator.frame = CGRectMake(0.0f, _backgroundView.frame.size.height, self.view.frame.size.width, TGScreenPixel);
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    if (self.view.frame.size.width > self.view.frame.size.height)
        orientation = UIInterfaceOrientationLandscapeLeft;
    _toolbarView.safeAreaInset = [TGViewController safeAreaInsetForOrientation:orientation];
}

- (CGFloat)textWidthForWidth:(CGFloat)width
{
    return width - 16.0f * 2;
}

- (CGFloat)textHeightForWidth:(CGFloat)__unused width
{
    CGFloat height = 0.0f;
    
    if ([_textModel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        return height;
    
    return _textModel.frame.size.height;
}

@end
