#import "TGSearchChatMembersController.h"
#import "TGSearchChatMembersControllerView.h"

#import "TGChannelManagementSignals.h"

#import "TGDatabase.h"

@interface TGSearchChatMembersController () {
    int64_t _peerId;
    int64_t _accessHash;
    void (^_completion)(TGUser *, TGCachedConversationMember *);
    bool _includeContacts;
    
    TGSearchChatMembersControllerView *_controllerView;
    
    NSArray<TGUser *> *_users;
    NSDictionary<NSNumber *, TGCachedConversationMember *> *_memberDatas;
    
    id<SDisposable> _channelMembersDisposable;
    SMetaDisposable *_searchDisposable;
}

@end

@implementation TGSearchChatMembersController

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash includeContacts:(bool)__unused includeContacts completion:(void (^)(TGUser *, TGCachedConversationMember *))completion {
    self = [super init];
    if (self != nil) {
        _peerId = peerId;
        _accessHash = accessHash;
        _completion = [completion copy];
        _includeContacts = true;//includeContacts;
        
        _searchDisposable = [[SMetaDisposable alloc] init];
        
        self.title = TGLocalized(@"Channel.Members.Title");
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)];
        
        SSignal *cachedSignal = [[[TGDatabaseInstance() channelCachedData:peerId] take:1] mapToSignal:^SSignal *(TGCachedConversationData *cachedData) {
            if (cachedData.generalMembers.count == 0) {
                return [SSignal complete];
            } else {
                NSMutableArray *users = [[NSMutableArray alloc] init];
                NSMutableDictionary *memberDatas = [[NSMutableDictionary alloc] init];
                for (TGCachedConversationMember *member in cachedData.generalMembers) {
                    TGUser *user = [TGDatabaseInstance() loadUser:member.uid];
                    if (user != nil) {
                        [users addObject:user];
                        memberDatas[@(member.uid)] = member;
                    }
                }
                return [SSignal single:@{@"users": users, @"memberDatas": memberDatas}];
            }
        }];
        SSignal *signal = [cachedSignal then:[[TGChannelManagementSignals channelMembers:peerId accessHash:accessHash offset:0 count:128] onNext:^(NSDictionary *dict) {
            
            [TGDatabaseInstance() updateChannelCachedData:peerId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                if (data == nil) {
                    data = [[TGCachedConversationData alloc] init];
                }
                return [data updateGeneralMembers:[dict[@"memberDatas"] allValues]];
            }];
        }]];
        
        __weak TGSearchChatMembersController *weakSelf = self;
        _channelMembersDisposable = [[signal deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *dict) {
            __strong TGSearchChatMembersController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                TGDispatchOnMainThread(^{
                    strongSelf->_users = dict[@"users"];
                    strongSelf->_memberDatas = dict[@"memberDatas"];
                    if ([strongSelf isViewLoaded]) {
                        [strongSelf->_controllerView setUsers:dict[@"users"] memberDatas:dict[@"memberDatas"]];
                    }
                });
            }
        }];
    }
    return self;
}

- (void)dealloc {
    [_channelMembersDisposable dispose];
    [_searchDisposable dispose];
}

- (void)cancelPressed {
    if (_completion) {
        _completion(nil, nil);
    }
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    __weak TGSearchChatMembersController *weakSelf = self;
    _controllerView = [[TGSearchChatMembersControllerView alloc] initWithFrame:self.view.bounds updateNavigationBarHidden:^(bool hidden, bool animated) {
        __strong TGSearchChatMembersController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf setNavigationBarHidden:hidden animated:animated];
        }
    } peerId:_peerId accessHash:_accessHash includeContacts:_includeContacts completion:^(TGUser *user, TGCachedConversationMember *member) {
        __strong TGSearchChatMembersController *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_completion) {
            strongSelf->_completion(user, member);
        }
    }];
    _controllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_controllerView];
    
    [_controllerView setUsers:_users memberDatas:_memberDatas];
    
    self.scrollViewsForAutomaticInsetsAdjustment = @[_controllerView.tableView];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset {
    [_controllerView controllerInsetUpdated:previousInset controllerInset:self.controllerInset navigationBarShouldBeHidden:self.navigationBarShouldBeHidden];
    
    [super controllerInsetUpdated:previousInset];
}

@end
