#import "TGAdSignals.h"

#import "TL/TLMetaScheme.h"
#import "TGTelegramNetworking.h"
#import "TGDatabase.h"
#import <SSignalKit/SSignalKit.h>
#import <MTProtoKit/MTProtoKit.h>
#import <LegacyComponents/LegacyComponents.h>
#import "TGUserDataRequestBuilder.h"
#import "TGConversation+Telegraph.h"

#import "TLRPChelp_getProxyData.h"
#import "TLhelp_ProxyData.h"

#import "TGChannelStateSignals.h"

@interface TGAdConversationContext: NSObject<ASWatcher> {
    void (^_next)(TGConversation *);
    
    int64_t _peerId;
    SVariable *_valuePromise;
    id<SDisposable> _valueDisposable;
    SMetaDisposable *_channelDisposable;
}

@property (nonatomic, strong, readonly) ASHandle *actionHandle;

@end

@implementation TGAdConversationContext

- (instancetype)initWithNext:(void (^)(TGConversation *))next {
    self = [super init];
    if (self != nil) {
        _next = [next copy];
        
        TGConversation *conversation = nil;
        NSData *data = [TGDatabaseInstance() customProperty:@"ad-item-id"];
        int64_t peerId = 0;
        if (data != nil && data.length == 8) {
            [data getBytes:&peerId length:8];
        }
        if (peerId != 0) {
            _peerId = peerId;
            conversation = [TGDatabaseInstance() loadConversationWithId:peerId];
            if ((conversation.messageDate != conversation.chatCreationDate || conversation.pts > 1) && conversation.kind != TGConversationKindPersistentChannel) {
            } else {
                conversation = nil;
            }
            [_channelDisposable setDisposable:[[TGChannelStateSignals updatedChannel:peerId] startWithNext:nil]];
        }
        
        _valuePromise = [[SVariable alloc] init];
        [_valuePromise set:[SSignal single:conversation]];
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        [ActionStageInstance() watchForPaths:@[
            @"/adItemId",
            @"/tg/conversations"
        ] watcher:self];
        _valueDisposable = [_valuePromise.signal startWithNext:^(id value) {
            next(value);
        }];
        _channelDisposable = [[SMetaDisposable alloc] init];
    }
    return self;
}

- (void)dealloc {
    [ActionStageInstance() removeWatcher:self];
    [_valueDisposable dispose];
    [_channelDisposable dispose];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments {
    if ([path isEqualToString:@"/adItemId"]) {
        [ActionStageInstance() dispatchOnStageQueue:^{
            TGConversation *conversation = nil;
            if (resource != nil) {
                _peerId = [resource longLongValue];
                conversation = [TGDatabaseInstance() loadConversationWithId:_peerId];
                if ((conversation.messageDate != conversation.chatCreationDate || conversation.pts > 1) && conversation.kind != TGConversationKindPersistentChannel) {
                } else {
                    conversation = nil;
                }
                [_channelDisposable setDisposable:[[TGChannelStateSignals updatedChannel:_peerId] startWithNext:nil]];
            } else {
                _peerId = 0;
                [_channelDisposable setDisposable:nil];
            }
            [_valuePromise set:[SSignal single:conversation]];
        }];
    } else if ([path isEqualToString:@"/tg/conversations"]) {
        [ActionStageInstance() dispatchOnStageQueue:^{
            if (_peerId != 0) {
                NSArray *conversations = ((SGraphObjectNode *)resource).object;
                for (TGConversation *conversation in conversations) {
                    if (conversation.conversationId == _peerId) {
                        if ((conversation.messageDate != conversation.chatCreationDate || conversation.pts > 1) && conversation.kind != TGConversationKindPersistentChannel) {
                            [_valuePromise set:[SSignal single:conversation]];
                        } else {
                            [_valuePromise set:[SSignal single:nil]];
                        }
                        break;
                    }
                }
            }
        }];
    }
}

@end

@implementation TGAdSignals

+ (SSignal *)remoteProxy {
    return [[[TGTelegramNetworking instance] requestSignal:[[TLRPChelp_getProxyData alloc] init]] map:^id (TLhelp_ProxyData *result) {
        int64_t peerId = 0;
        if ([result isKindOfClass:[TLhelp_ProxyData$proxyDataPromo class]]) {
            TLhelp_ProxyData$proxyDataPromo *promo = (TLhelp_ProxyData$proxyDataPromo *)result;
            if ([promo.peer isKindOfClass:[TLPeer$peerChannel class]]) {
                TLPeer$peerChannel *channel = (TLPeer$peerChannel *)promo.peer;
                peerId = TGPeerIdFromChannelId(channel.channel_id);
            }
            
            [TGUserDataRequestBuilder executeUserDataUpdate:promo.users];
            
            NSMutableDictionary *chats = [[NSMutableDictionary alloc] init];
            
            for (TLChat *chatDesc in promo.chats) {
                TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chatDesc];
                if (conversation != nil) {
                    [chats setObject:conversation forKey:[[NSNumber alloc] initWithLongLong:conversation.conversationId]];
                }
            }
            
            [TGDatabaseInstance() transactionAddMessages:nil updateConversationDatas:chats notifyAdded:false];
        }
        return @(peerId);
    }];
}

+ (SSignal *)updatedAdItemId {
    SSignal *signal = [[[[TGTelegramNetworking instance] socksProxySettings] mapToSignal:^SSignal *(MTSocksProxySettings *settings) {
        if (settings.secret != nil) {
            return [[[self remoteProxy] then:[[SSignal complete] delay:10.0 * 60.0 onQueue:[SQueue mainQueue]]] restart];
        } else {
            return [SSignal single:@0];
        }
    }] ignoreRepeated];
    
    return [signal mapToSignal:^SSignal *(NSNumber *nPeerId) {
        return [TGDatabaseInstance() modify:^id{
            NSData *data = [TGDatabaseInstance() customProperty:@"ad-item-id"];
            int64_t peerId = 0;
            if (data != nil && data.length == 8) {
                [data getBytes:&peerId length:8];
            }
            
            int64_t updatedPeerId = [nPeerId longLongValue];
            
            if (peerId != updatedPeerId) {
                [TGDatabaseInstance() setCustomProperty:@"ad-item-id" value:[NSData dataWithBytes:&updatedPeerId length:8]];
                [ActionStageInstance() dispatchResource:@"/adItemId" resource:updatedPeerId == 0 ? nil : @(updatedPeerId)];
            }
            
            return nil;
        }];
    }];
}

+ (SSignal *)adChatListConversation {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        id<SDisposable> updatedDisposable = [[self updatedAdItemId] startWithNext:nil];
        
        TGAdConversationContext *context = [[TGAdConversationContext alloc] initWithNext:^(TGConversation *conversation) {
            [subscriber putNext:conversation];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^{
            [updatedDisposable dispose];
            [context description];
        }];
    }];
}

@end
