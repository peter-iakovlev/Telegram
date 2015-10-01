#import "TGBridgeChatMessageListHandler.h"

#import "TGTelegraph.h"

#import "TGMessage.h"
#import "TGDatabase.h"
#import "TGChatMessageListSignal.h"
#import "TGUserSignal.h"

#import "TGBridgeMessage+TGMessage.h"
#import "TGBridgeChat+TGConversation.h"
#import "TGBridgeChatMessageListView+TGChatMessageListView.h"
#import "TGBridgeUser+TGUser.h"

#import "TGPeerIdAdapter.h"

@implementation TGBridgeChatMessageListHandler

+ (SSignal *)handlingSignalForSubscription:(TGBridgeSubscription *)subscription server:(TGBridgeServer *)__unused server
{
    if ([subscription isKindOfClass:[TGBridgeChatMessageListSubscription class]])
    {
        TGBridgeChatMessageListSubscription *messagesListSubscription = (TGBridgeChatMessageListSubscription *)subscription;
        
        SSignal *(^messageHandler)(TGChatMessageListView *) = ^(TGChatMessageListView *messageListView)
        {
            NSMutableIndexSet *userIds = [[NSMutableIndexSet alloc] init];
            if (messagesListSubscription.peerId > 0 && !TGPeerIdIsChannel(messagesListSubscription.peerId))
                [userIds addIndex:(int32_t)messagesListSubscription.peerId];
            
            for (TGMessage *message in messageListView.messages)
                [userIds addIndexes:[TGBridgeChatMessageListHandler involvedUserIdsForTGMessage:message]];
            
            TGBridgeChatMessageListView *bridgeMessageListView = [TGBridgeChatMessageListView chatMessageListViewWithTGChatMessageListView:messageListView isChannel:TGPeerIdIsChannel(messagesListSubscription.peerId)];
            
            NSMutableArray *userSignals = [[NSMutableArray alloc] init];
            [userIds enumerateIndexesUsingBlock:^(NSUInteger index, __unused BOOL *stop)
            {
                [userSignals addObject:[TGUserSignal userWithUserId:(int32_t)index]];
            }];
            
            SSignal *combinedUserSignal = [SSignal single:nil];
            if (userSignals.count > 0)
                combinedUserSignal = [SSignal combineSignals:userSignals];
            
            return [combinedUserSignal map:^id(NSArray *users)
            {
                NSMutableDictionary *bridgeUsers = [[NSMutableDictionary alloc] init];
                for (TGUser *user in users)
                {
                    TGBridgeUser *bridgeUser = [TGBridgeUser userWithTGUser:user];
                    if (bridgeUser != nil)
                        bridgeUsers[@(bridgeUser.identifier)] = bridgeUser;
                }
                
                return @{ TGBridgeChatMessageListViewKey: bridgeMessageListView, TGBridgeUsersDictionaryKey: bridgeUsers };
            }];
        };
        
        return [[TGChatMessageListSignal chatMessageListViewWithPeerId:messagesListSubscription.peerId atMessageId:messagesListSubscription.atMessageId rangeMessageCount:messagesListSubscription.rangeMessageCount] mapToSignal:^SSignal *(TGChatMessageListView *messageListView)
        {
            return messageHandler(messageListView);
        }];
    }
    else if ([subscription isKindOfClass:[TGBridgeChatMessageSubscription class]])
    {
        TGBridgeChatMessageSubscription *messageSubscription = (TGBridgeChatMessageSubscription *)subscription;
        
        return [[[[[TGChatMessageListSignal chatMessageListViewWithPeerId:messageSubscription.peerId atMessageId:0 rangeMessageCount:24] filter:^bool(TGChatMessageListView *messageListView)
        {
            for (TGMessage *message in messageListView.messages)
            {
                if (message.mid == messageSubscription.messageId)
                    return true;
            }
            
            return false;
        }] mapToSignal:^SSignal *(TGChatMessageListView *messageListView)
        {
            TGMessage *requiredMessage = nil;
            for (TGMessage *message in messageListView.messages)
            {
                if (message.mid == messageSubscription.messageId)
                {
                    requiredMessage = message;
                    break;
                }
            }
            
            NSMutableIndexSet *userIds = [[NSMutableIndexSet alloc] init];
            if (messageSubscription.peerId > 0)
                [userIds addIndex:(int32_t)messageSubscription.peerId];
            [userIds addIndexes:[TGBridgeChatMessageListHandler involvedUserIdsForTGMessage:requiredMessage]];
            
            TGBridgeMessage *bridgeMessage = [TGBridgeMessage messageWithTGMessage:requiredMessage];
            
            NSMutableArray *userSignals = [[NSMutableArray alloc] init];
            [userIds enumerateIndexesUsingBlock:^(NSUInteger index, __unused BOOL *stop)
            {
                [userSignals addObject:[TGUserSignal userWithUserId:(int32_t)index]];
            }];
            
            SSignal *combinedUserSignal = [SSignal single:nil];
            if (userSignals.count > 0)
                combinedUserSignal = [SSignal combineSignals:userSignals];
            
            return [combinedUserSignal map:^id(NSArray *users)
            {
                NSMutableDictionary *bridgeUsers = [[NSMutableDictionary alloc] init];
                for (TGUser *user in users)
                {
                    TGBridgeUser *bridgeUser = [TGBridgeUser userWithTGUser:user];
                    if (bridgeUser != nil)
                        bridgeUsers[@(bridgeUser.identifier)] = bridgeUser;
                }
                
                TGBridgeChat *bridgeChat = nil;
                if (TGPeerIdIsGroup(messageSubscription.peerId))
                {
                    TGConversation *conversation = [[TGDatabase instance] loadConversationWithId:messageSubscription.peerId];
                    if (conversation != nil)
                        bridgeChat = [TGBridgeChat chatWithTGConversation:conversation];
                }
                
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
                if (bridgeMessage != nil)
                    dictionary[TGBridgeMessageKey] = bridgeMessage;
                
                if (bridgeChat != nil)
                    dictionary[TGBridgeChatKey] = bridgeChat;
                
                if (bridgeUsers != nil)
                    dictionary[TGBridgeUsersDictionaryKey] = bridgeUsers;
                
                return dictionary;
            }];
        }] take:1] timeout:4.5 onQueue:[SQueue concurrentDefaultQueue] orSignal:[SSignal single:@0]];
    }
    else if ([subscription isKindOfClass:[TGBridgeReadChatMessageListSubscription class]])
    {
        TGBridgeReadChatMessageListSubscription *readMessagesListSubscription = (TGBridgeReadChatMessageListSubscription *)subscription;
        
        return [[TGChatMessageListSignal readChatMessageListWithPeerId:readMessagesListSubscription.peerId] mapToSignal:^SSignal *(__unused id next)
        {
            return [SSignal single:@true];
        }];
    }
    
    return nil;
}

+ (NSIndexSet *)involvedUserIdsForTGMessage:(TGMessage *)message
{
    NSMutableIndexSet *userIds = [[NSMutableIndexSet alloc] init];
    if (message.fromUid == 0)
        [userIds addIndex:TGTelegraphInstance.clientUserId];
    else if (!TGPeerIdIsChannel(message.fromUid))
        [userIds addIndex:(int32_t)message.fromUid];
    
    for (TGMediaAttachment *attachment in message.mediaAttachments)
    {
        if ([attachment isKindOfClass:[TGContactMediaAttachment class]])
        {
            TGContactMediaAttachment *contactAttachment = (TGContactMediaAttachment *)attachment;
            if (contactAttachment.uid != 0)
                [userIds addIndex:contactAttachment.uid];
        }
        else if ([attachment isKindOfClass:[TGForwardedMessageMediaAttachment class]])
        {
            TGForwardedMessageMediaAttachment *forwardAttachment = (TGForwardedMessageMediaAttachment *)attachment;
            if (forwardAttachment.forwardPeerId != 0 && !TGPeerIdIsChannel(forwardAttachment.forwardPeerId))
            {
                [userIds addIndex:(int32_t)forwardAttachment.forwardPeerId];
            }
        }
        else if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]])
        {
            TGReplyMessageMediaAttachment *replyAttachment = (TGReplyMessageMediaAttachment *)attachment;
            if (replyAttachment.replyMessage != nil && !TGPeerIdIsChannel(replyAttachment.replyMessage.fromUid))
                [userIds addIndex:(int32_t)replyAttachment.replyMessage.fromUid];
        }
        else if ([attachment isKindOfClass:[TGActionMediaAttachment class]])
        {
            TGActionMediaAttachment *actionAttachment = (TGActionMediaAttachment *)attachment;
            if (actionAttachment.actionData[@"uid"] != nil)
                [userIds addIndex:[actionAttachment.actionData[@"uid"] int32Value]];
        }
    }
    
    return userIds;
}

+ (NSArray *)handledSubscriptions
{
    return @[ [TGBridgeChatMessageListSubscription class], [TGBridgeChatMessageSubscription class], [TGBridgeReadChatMessageListSubscription class] ];
}

@end
