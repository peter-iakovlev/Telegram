#import "TGAuthSessionsController.h"

#import <LegacyComponents/ActionStage.h>

#import "TGAuthSession.h"
#import "TGAppSession.h"
#import "TGAuthSessionListSignals.h"

#import "TGHeaderCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGAuthSessionItem.h"
#import "TGAppSessionItem.h"

#import <LegacyComponents/TGProgressWindow.h>
#import "TGCustomActionSheet.h"

#import "TGAuthSessionsEmptyView.h"

#import "TGSegmentedTitleView.h"

#import "TGPresentation.h"

@interface TGAuthSessionsController () <ASWatcher>
{
    bool _viewingAppSessions;
    NSArray *_authSessions;
    NSArray *_appSessions;
    UIActivityIndicatorView *_activityIndicatorView;
    TGAuthSessionsEmptyView *_emptyView;
    
    TGSegmentedTitleView *_segmentedTitleView;
    
    SMetaDisposable *_authSessionListDisposable;
    SMetaDisposable *_removeSessionDisposable;
    
    SMetaDisposable *_appSessionListDisposable;
    
    bool _editing;
    bool _editButtonHidden;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGAuthSessionsController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _authSessionListDisposable = [[SMetaDisposable alloc] init];
        _removeSessionDisposable = [[SMetaDisposable alloc] init];
        
        _appSessionListDisposable = [[SMetaDisposable alloc] init];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [self updateSessionList];
    }
    return self;
}

- (void)dealloc
{
    [_authSessionListDisposable dispose];
    [_removeSessionDisposable dispose];
    
    [_appSessionListDisposable dispose];
    
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    [_segmentedTitleView setPresentation:presentation];
}

- (void)updateSessionList
{
    __weak TGAuthSessionsController *weakSelf = self;
    [_authSessionListDisposable setDisposable:[[[TGAuthSessionListSignals authSessionList] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *authSessions)
    {
        __strong TGAuthSessionsController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf->_activityIndicatorView removeFromSuperview];
            strongSelf->_activityIndicatorView = nil;
            [strongSelf setAuthSessions:authSessions];
            
            [strongSelf updateAppSessionsList];
        }
    }]];
}

- (void)updateAppSessionsList
{
    __weak TGAuthSessionsController *weakSelf = self;
    [_appSessionListDisposable setDisposable:[[[TGAuthSessionListSignals loggedAppsSessionList] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *appSessions)
    {
        __strong TGAuthSessionsController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf setAppSessions:appSessions];
        }
    }]];
}

- (void)loadView
{
    [super loadView];
    
    self.collectionView.alpha = 0.0f;
    
    _emptyView = [[TGAuthSessionsEmptyView alloc] initWithFrame:self.view.bounds];
    _emptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:_emptyView belowSubview:self.collectionView];
    _emptyView.hidden = _authSessions.count == 0 || _authSessions.count > 1;
    
    if (_activityIndicatorView != nil)
    {
        _activityIndicatorView.frame = CGRectMake(CGFloor((self.view.frame.size.width - _activityIndicatorView.frame.size.width) / 2.0f), CGFloor((self.view.frame.size.height - _activityIndicatorView.frame.size.height) / 2.0f), _activityIndicatorView.frame.size.width, _activityIndicatorView.frame.size.height);
        _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _activityIndicatorView.color = self.presentation.pallete.collectionMenuCommentColor;
        [_activityIndicatorView startAnimating];
        [self.view addSubview:_activityIndicatorView];
    }
    
    NSArray *items = @[TGLocalized(@"AuthSessions.Sessions"), TGLocalized(@"AuthSessions.LoggedIn")];
    _segmentedTitleView = [[TGSegmentedTitleView alloc] initWithTitle:TGLocalized(@"AuthSessions.Title") segments:items];
    [_segmentedTitleView setPresentation:self.presentation];
    __weak TGAuthSessionsController *weakSelf = self;
    _segmentedTitleView.segmentChanged = ^(NSInteger selectedIndex)
    {
        __strong TGAuthSessionsController *strongSelf = weakSelf;
        if (strongSelf)
            [strongSelf setAppSessionsSelected:selectedIndex == 1];
    };
    [self setTitleView:_segmentedTitleView];
}

- (void)setAuthSessions:(NSArray *)authSessions
{
    _authSessions = authSessions;
    [self _update:false];
}

- (void)setAppSessions:(NSArray *)appSessions
{
    _appSessions = appSessions;
    bool hidden = appSessions.count == 0;
    [_segmentedTitleView setSegmentedControlHidden:hidden animated:true];
    
    bool changed = false;
    if (appSessions.count == 0 && _viewingAppSessions)
    {
        changed = true;
        _viewingAppSessions = false;
    }
    
    [self _update:changed];
}

- (void)setAppSessionsSelected:(bool)appSessions
{
    bool changed = _viewingAppSessions != appSessions;
    _viewingAppSessions = appSessions;
    
    [self _update:changed];
}

- (void)_update:(bool)changed
{
    if (changed)
    {
        UIView *snapshotView = [self.collectionView snapshotViewAfterScreenUpdates:false];
        [self.view insertSubview:snapshotView aboveSubview:self.collectionView];
        
        [UIView animateWithDuration:0.2 animations:^
        {
            snapshotView.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            [snapshotView removeFromSuperview];
        }];
        
        self.collectionView.alpha = 0.0f;
    }
    
    if (_viewingAppSessions)
    {
        if (changed)
        {
            [UIView animateWithDuration:0.2 animations:^
            {
                self.collectionView.alpha = 1.0f;
            }];
        }
        
        while (self.menuSections.sections.count != 0)
        {
            [self.menuSections deleteSection:0];
        }
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        TGButtonCollectionItem *resetItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"AuthSessions.LogOutApplications") action:@selector(resetAppSessionsPressed)];
        resetItem.titleColor = self.presentation.pallete.collectionMenuDestructiveColor;
        resetItem.deselectAutomatically = true;
        [items addObject:resetItem];
        
        [items addObject:[[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"AuthSessions.LogOutApplicationsHelp")]];
        
        TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:items];
        UIEdgeInsets topSectionInsets = section.insets;
        topSectionInsets.top = 32.0f;
        section.insets = topSectionInsets;
        [self.menuSections addSection:section];
        
        items = [[NSMutableArray alloc] init];
        
        NSArray *sessions = @[];
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:_appSessions];
        [array sortUsingComparator:^NSComparisonResult(TGAppSession *session1, TGAppSession *session2)
        {
            return session1.dateActive > session2.dateActive ? NSOrderedAscending : NSOrderedDescending;
        }];
        sessions = array;
        
        [items addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"AuthSessions.LoggedInWithTelegram")]];
        
        for (TGAppSession *appSession in sessions)
        {
            __weak TGAuthSessionsController *weakSelf = self;
            [items addObject:[[TGAppSessionItem alloc] initWithAppSession:appSession removeRequested:^
            {
                __strong TGAuthSessionsController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf removeAppSession:appSession];
            }]];
        }
        
        TGCollectionMenuSection *sessionsSection = [[TGCollectionMenuSection alloc] initWithItems:items];
        [self.menuSections addSection:sessionsSection];
        
        if (!_editing)
        {
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)]];
        }

        [self.collectionView reloadData];
    }
    else
    {
        if (changed || (_authSessions.count > 0 && self.collectionView.alpha < FLT_EPSILON))
        {
            [UIView animateWithDuration:0.2 animations:^
            {
                self.collectionView.alpha = 1.0f;
            }];
        }
        
        while (self.menuSections.sections.count != 0)
        {
            [self.menuSections deleteSection:0];
        }
        
        TGAuthSession *currentSession = nil;
        NSArray *otherSessions = @[];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (TGAuthSession *session in _authSessions)
        {
            if (session.sessionHash == 0)
                currentSession = session;
            else
                [array addObject:session];
        }
        [array sortUsingComparator:^NSComparisonResult(TGAuthSession *session1, TGAuthSession *session2)
         {
             return session1.dateActive > session2.dateActive ? NSOrderedAscending : NSOrderedDescending;
         }];
        otherSessions = array;
        
        if (currentSession != nil)
        {
            NSMutableArray *items = [[NSMutableArray alloc] init];
            
            [items addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"AuthSessions.CurrentSession")]];
            [items addObject:[[TGAuthSessionItem alloc] initWithAuthSession:currentSession removeRequested:nil]];
            
            if (otherSessions.count != 0)
            {
                TGButtonCollectionItem *resetItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"AuthSessions.TerminateOtherSessions") action:@selector(resetSessionsPressed)];
                resetItem.titleColor = self.presentation.pallete.collectionMenuDestructiveColor;
                resetItem.deselectAutomatically = true;
                [items addObject:resetItem];
                
                [items addObject:[[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"AuthSessions.TerminateOtherSessionsHelp")]];
            }
            
            TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:items];
            UIEdgeInsets topSectionInsets = section.insets;
            topSectionInsets.top = 32.0f;
            section.insets = topSectionInsets;
            [self.menuSections addSection:section];
        }
        
        if (otherSessions.count != 0)
        {
            NSMutableArray *items = [[NSMutableArray alloc] init];
            [items addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"AuthSessions.OtherSessions")]];
            
            for (TGAuthSession *authSession in otherSessions)
            {
                __weak TGAuthSessionsController *weakSelf = self;
                [items addObject:[[TGAuthSessionItem alloc] initWithAuthSession:authSession removeRequested:^
                {
                    __strong TGAuthSessionsController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                        [strongSelf removeSession:authSession];
                }]];
            }
            
            TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:items];
            [self.menuSections addSection:section];
            
            if (!_editing)
            {
                [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)]];
            }
        }
        else
        {
            if (_editing)
            {
                _editing = false;
                [self leaveEditingMode:true];
            }
            [self setLeftBarButtonItem:nil];
            [self setRightBarButtonItem:nil];
        }
        
        [self.collectionView reloadData];
    }
    
    bool editButtonHidden = false;
    if (_appSessions.count > 0)
    {
        CGFloat backWidth = [TGLocalized(@"Common.Back") sizeWithFont:TGSystemFontOfSize(17.0f)].width;
        CGFloat editWidth = [TGLocalized(@"Common.Edit") sizeWithFont:TGSystemFontOfSize(17.0f)].width;
        CGFloat width = _segmentedTitleView.innerWidth + backWidth + editWidth;
        
        if (width > TGScreenSize().width - 44.0f && !_editing)
        {
            [self setRightBarButtonItem:nil];
            _editButtonHidden = true;
        }
    }
    _editButtonHidden = editButtonHidden;
}

- (void)editPressed
{
    [self enterEditingMode:true];
}

- (void)donePressed
{
    [self leaveEditingMode:true];
}

- (void)didEnterEditingMode:(bool)animated
{
    [super didEnterEditingMode:animated];
    
    if (_editButtonHidden)
        return;
    
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
}

- (void)didLeaveEditingMode:(bool)animated
{
    [super didLeaveEditingMode:animated];
    
    if (_editButtonHidden)
        return;
    
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)]];
}

- (void)resetSessionsPressed
{
    __weak TGAuthSessionsController *weakSelf = self;
    
    TGCustomActionSheet *actionSheet = [[TGCustomActionSheet alloc] initWithTitle:nil actions:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"AuthSessions.TerminateOtherSessions") action:@"remove" type:TGActionSheetActionTypeDestructive],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
    ] actionBlock:^(__unused id target, NSString *action)
    {
        if ([action isEqualToString:@"remove"])
        {
            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
            [progressWindow show:true];
            
            [_removeSessionDisposable setDisposable:[[[[TGAuthSessionListSignals removeAllOtherSessions] deliverOn:[SQueue mainQueue]] onDispose:^
            {
                TGDispatchOnMainThread(^
                {
                    [progressWindow dismiss:true];
                });
            }] startWithNext:^(NSArray *authSessions)
            {
                __strong TGAuthSessionsController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf setAuthSessions:authSessions];
            }]];
        }
    } target:self];
    [actionSheet showInView:self.view];
}

- (void)resetAppSessionsPressed
{
    __weak TGAuthSessionsController *weakSelf = self;
    
    TGCustomActionSheet *actionSheet = [[TGCustomActionSheet alloc] initWithTitle:nil actions:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"AuthSessions.LogOutApplications") action:@"remove" type:TGActionSheetActionTypeDestructive],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
        ] actionBlock:^(__unused id target, NSString *action)
    {
        if ([action isEqualToString:@"remove"])
        {
            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
            [progressWindow show:true];
            
            [_removeSessionDisposable setDisposable:[[[[TGAuthSessionListSignals removeAllAppSessions] deliverOn:[SQueue mainQueue]] onDispose:^
            {
                TGDispatchOnMainThread(^
                {
                    [progressWindow dismiss:true];
                });
            }] startWithNext:^(NSArray *authSessions)
            {
                __strong TGAuthSessionsController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf setAppSessions:authSessions];
            }]];
        }
    } target:self];
    [actionSheet showInView:self.view];
}

- (void)removeSession:(TGAuthSession *)authSession
{
    __weak TGAuthSessionsController *weakSelf = self;
    
    TGCustomActionSheet *actionSheet = [[TGCustomActionSheet alloc] initWithTitle:nil actions:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"AuthSessions.TerminateSession") action:@"remove" type:TGActionSheetActionTypeDestructive],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
    ] actionBlock:^(__unused id target, NSString *action)
    {
        if ([action isEqualToString:@"remove"])
        {
            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
            [progressWindow show:true];
            
            [_removeSessionDisposable setDisposable:[[[[TGAuthSessionListSignals removeSession:authSession] deliverOn:[SQueue mainQueue]] onDispose:^
            {
                TGDispatchOnMainThread(^
                {
                    [progressWindow dismiss:true];
                });
            }] startWithNext:^(NSArray *authSessions)
            {
                __strong TGAuthSessionsController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf setAuthSessions:authSessions];
            }]];
        }
    } target:self];
    [actionSheet showInView:self.view];
}

- (void)removeAppSession:(TGAppSession *)appSession
{
    __weak TGAuthSessionsController *weakSelf = self;
    
    TGCustomActionSheet *actionSheet = [[TGCustomActionSheet alloc] initWithTitle:nil actions:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"AuthSessions.LogOut") action:@"remove" type:TGActionSheetActionTypeDestructive],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
        ] actionBlock:^(__unused TGAuthSessionsController *target, NSString *action)
    {
        if ([action isEqualToString:@"remove"])
        {
            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
            [progressWindow show:true];
            
            [_removeSessionDisposable setDisposable:[[[[TGAuthSessionListSignals removeAppSession:appSession] deliverOn:[SQueue mainQueue]] onDispose:^
            {
                TGDispatchOnMainThread(^
                {
                    [progressWindow dismiss:true];
                });
            }] startWithNext:^(NSArray *appSessions)
            {
                __strong TGAuthSessionsController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf setAppSessions:appSessions];
            }]];
        }
    } target:self];
    [actionSheet showInView:self.view];
}

@end
