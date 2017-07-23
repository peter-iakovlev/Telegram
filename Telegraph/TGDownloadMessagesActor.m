/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGDownloadMessagesActor.h"

#import "TGUserDataRequestBuilder.h"

#import "ActionStage.h"

#import "TGTelegraph.h"

#import "TGMessage+Telegraph.h"

#import "TGDatabase.h"

@implementation TGDownloadMessagesActor

+ (NSString *)genericPath
{
    return @"/tg/downloadMessages/@";
}

- (void)execute:(NSDictionary *)options
{
    NSArray *mids = options[@"mids"];
    
    self.cancelToken = [TGTelegraphInstance doDownloadMessages:mids peerId:[options[@"peerId"] longLongValue] accessHash:[options[@"accessHash"] longLongValue] actor:self];
}

- (void)messagesRequestSuccess:(TLmessages_Messages *)messages
{
    NSMutableArray *messageUpdates = [[NSMutableArray alloc] init];
    NSMutableDictionary *messagesByConversation = [[NSMutableDictionary alloc] init];
    
    [TGUserDataRequestBuilder executeUserDataUpdate:messages.users];
    
    for (TLMessage *messageDesc in messages.messages)
    {
        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
        if (message.mid != 0)
        {
            [messageUpdates addObject:[[TGDatabaseUpdateMessageWithMessage alloc] initWithPeerId:message.cid messageId:message.mid message:message dispatchEdited:false]];
            
            NSMutableArray *conversationMessages = messagesByConversation[@(message.cid)];
            if (conversationMessages == nil)
            {
                conversationMessages = [[NSMutableArray alloc] init];
                messagesByConversation[@(message.cid)] = conversationMessages;
            }
            
            [conversationMessages addObject:message];
        }
    }
    
    [TGDatabaseInstance() transactionUpdateMessages:messageUpdates updateConversationDatas:@{}];
    
    [ActionStageInstance() actionCompleted:self.path result:@{@"messagesByConversation": messagesByConversation}];
}

- (void)messagesRequestFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
