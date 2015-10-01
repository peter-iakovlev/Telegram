#import "TGAuthSessionsController.h"

#import "ActionStage.h"

#import "TGAuthSession.h"
#import "TGAuthSessionListSignals.h"

#import "TGHeaderCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGAuthSessionItem.h"

#import "TGProgressWindow.h"
#import "TGActionSheet.h"

#import "TGAuthSessionsEmptyView.h"

@interface TGAuthSessionsController () <ASWatcher>
{
    NSArray *_authSessions;
    UIActivityIndicatorView *_activityIndicatorView;
    TGAuthSessionsEmptyView *_emptyView;
    
    SMetaDisposable *_authSessionListDisposable;
    SMetaDisposable *_removeSessionDisposable;
    
    bool _editing;
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
        
        self.title = TGLocalized(@"AuthSessions.Title");
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [self updateSessionList];
        
        [ActionStageInstance() watchForPath:@"/sessionListUpdated" watcher:self];
    }
    return self;
}

- (void)dealloc
{
    [_authSessionListDisposable dispose];
    [_removeSessionDisposable dispose];
    
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
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
        }
    }]];
}

- (void)loadView
{
    [super loadView];
    
    _emptyView = [[TGAuthSessionsEmptyView alloc] initWithFrame:self.view.bounds];
    _emptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:_emptyView belowSubview:self.collectionView];
    _emptyView.hidden = _authSessions.count == 0 || _authSessions.count > 1;
    
    if (_activityIndicatorView != nil)
    {
        _activityIndicatorView.frame = CGRectMake(CGFloor((self.view.frame.size.width - _activityIndicatorView.frame.size.width) / 2.0f), CGFloor((self.view.frame.size.height - _activityIndicatorView.frame.size.height) / 2.0f), _activityIndicatorView.frame.size.width, _activityIndicatorView.frame.size.height);
        _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_activityIndicatorView startAnimating];
        [self.view addSubview:_activityIndicatorView];
    }
}

- (void)setAuthSessions:(NSArray *)authSessions
{
    _authSessions = authSessions;
    _emptyView.hidden = _authSessions.count > 1;
    
    while (self.menuSections.sections.count != 0)
    {
        [self.menuSections deleteSection:0];
    }
    
    TGAuthSession *currentSession = nil;
    NSArray *otherSessions = @[];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (TGAuthSession *session in authSessions)
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
            resetItem.titleColor = TGDestructiveAccentColor();
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

- (void)editPressed
{
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
    [self enterEditingMode:true];
}

- (void)donePressed
{
    [self leaveEditingMode:true];
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)]];
}

- (void)resetSessionsPressed
{
    __weak TGAuthSessionsController *weakSelf = self;
    
    TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:nil actions:@[
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

- (void)removeSession:(TGAuthSession *)authSession
{
    __weak TGAuthSessionsController *weakSelf = self;
    
    TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:nil actions:@[
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

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)__unused resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/sessionListUpdated"])
    {
        TGDispatchOnMainThread(^
        {
            [self updateSessionList];
        });
    }
}

@end
