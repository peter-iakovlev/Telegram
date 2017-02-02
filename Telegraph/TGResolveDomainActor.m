#import "TGResolveDomainActor.h"

#import "ActionStage.h"
#import "TGTelegramNetworking.h"
#import "TGProgressWindow.h"

#import "TL/TLMetaScheme.h"

#import <MTProtoKit/MTRequest.h>

#import "TGUserDataRequestBuilder.h"
#import "TGUser+Telegraph.h"
#import "TGConversation+Telegraph.h"

#import "TGInterfaceManager.h"

#import "TGAppDelegate.h"

#import "TGChannelManagementSignals.h"

#import "TGAlertView.h"

@interface TGResolveDomainActor ()
{
    TGProgressWindow *_progressWindow;
    NSString *_domain;
    bool _profile;
    bool _keepStack;
    NSDictionary *_arguments;
}

@end

@implementation TGResolveDomainActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/resolveDomain/@";
}

- (void)dealloc
{
    TGProgressWindow *progressWindow = _progressWindow;
    TGDispatchOnMainThread(^
    {
        [progressWindow dismiss:true];
    });
}

- (void)execute:(NSDictionary *)options
{
    TGDispatchOnMainThread(^
    {
        _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_progressWindow show:true];
    });
    
    _domain = options[@"domain"];
    _profile = [options[@"profile"] boolValue];
    _arguments = options[@"arguments"];
    _keepStack = [options[@"keepStack"] boolValue];
    
    MTRequest *request = [[MTRequest alloc] init];
    
    TLRPCcontacts_resolveUsername$contacts_resolveUsername *resolveUsername = [[TLRPCcontacts_resolveUsername$contacts_resolveUsername alloc] init];
    resolveUsername.username = _domain;
    request.body = resolveUsername;
    
    __weak TGResolveDomainActor *weakSelf = self;
    [request setCompleted:^(TLcontacts_ResolvedPeer *resolvedPeer, __unused NSTimeInterval timestamp, id error)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            __strong TGResolveDomainActor *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (error == nil) {
                    [strongSelf resolveSuccess:resolvedPeer];
                } else {
                    [strongSelf resolveFailed:[[TGTelegramNetworking instance] extractNetworkErrorType:error]];
                }
            }
        }];
    }];
    
    self.cancelToken = request.internalId;
    [[TGTelegramNetworking instance] addRequest:request];
}

- (void)resolveSuccess:(TLcontacts_ResolvedPeer *)resolvedPeer
{
    if ([resolvedPeer.peer isKindOfClass:[TLPeer$peerUser class]] && resolvedPeer.users.count != 0)
    {
        TGDispatchOnMainThread(^ {
            [_progressWindow dismiss:true];
            _progressWindow = nil;
        });
        TGUser *user = [[TGUser alloc] initWithTelegraphUserDesc:resolvedPeer.users[0]];
        if (user.uid != 0)
        {
            [TGUserDataRequestBuilder executeUserObjectsUpdate:@[user]];
            TGDispatchOnMainThread(^
            {
                if (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot)
                {
                    if (_arguments[@"start"] != nil)
                    {
                        [[TGInterfaceManager instance] navigateToConversationWithId:user.uid conversation:nil performActions:@{@"botStartPayload": _arguments[@"start"]}];
                        return;
                    }
                    else if (_arguments[@"startgroup"] != nil && user.botKind != TGBotKindPrivate)
                    {
                        [TGAppDelegateInstance inviteBotToGroup:user payload:_arguments[@"startgroup"]];
                        return;
                    }
                    else if (_arguments[@"game"] != nil)
                    {
                        [TGAppDelegateInstance startGameInConversation:_arguments[@"game"] user:user];
                        return;
                    }
                }
                
                if (_profile) {
                    if (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot) {
                        [[TGInterfaceManager instance] navigateToConversationWithId:user.uid conversation:nil performActions:nil atMessage:nil clearStack:!_keepStack openKeyboard:false canOpenKeyboardWhileInTransition:false animated:true];
                    } else {
                        [[TGInterfaceManager instance] navigateToProfileOfUser:user.uid shareVCard:nil];
                    }
                }
                else {
                    [[TGInterfaceManager instance] navigateToConversationWithId:user.uid conversation:nil performActions:nil atMessage:nil clearStack:!_keepStack openKeyboard:false canOpenKeyboardWhileInTransition:false animated:true];
                }
            });
        }
    }
    else if ([resolvedPeer.peer isKindOfClass:[TLPeer$peerChannel class]] && resolvedPeer.chats.count != 0)
    {
        TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:resolvedPeer.chats[0]];
        conversation.kind = TGConversationKindTemporaryChannel;
        
        TGProgressWindow *progressWindow = _progressWindow;
        SSignal *channelSignal = [TGChannelManagementSignals addChannel:conversation];
        if ([_arguments[@"messageId"] intValue] != 0) {
            channelSignal = [channelSignal then:[TGChannelManagementSignals preloadedChannelAtMessage:conversation.conversationId messageId:[_arguments[@"messageId"] intValue]]];
        }
        
        [[[[channelSignal deliverOn:[SQueue mainQueue]] onDispose:^{
            TGDispatchOnMainThread(^ {
                [progressWindow dismiss:true];
            });
        }] takeLast] startWithNext:^(TGConversation *next) {
            [[TGInterfaceManager instance] navigateToConversationWithId:conversation.conversationId conversation:next performActions:@{} atMessage:@{@"mid": @([_arguments[@"messageId"] intValue])} clearStack:!_keepStack openKeyboard:false canOpenKeyboardWhileInTransition:false animated:true];
        }error:nil completed:nil];
    }
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)resolveFailed:(NSString *)__unused errorType
{
    TGDispatchOnMainThread(^
    {
        [_progressWindow dismiss:true];
        _progressWindow = nil;
        
        [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Resolve.ErrorNotFound") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
    });

    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
