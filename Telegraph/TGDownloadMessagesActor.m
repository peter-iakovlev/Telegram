/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGDownloadMessagesActor.h"

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
    
    self.cancelToken = [TGTelegraphInstance doDownloadMessages:mids actor:self];
}

- (void)messagesRequestSuccess:(TLmessages_Messages *)messages
{
    NSMutableDictionary *messagesByConversation = [[NSMutableDictionary alloc] init];
    
    for (TLMessage *messageDesc in messages.messages)
    {
        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
        if (message.mid != 0)
        {
            NSMutableArray *conversationMessages = messagesByConversation[@(message.cid)];
            if (conversationMessages == nil)
            {
                conversationMessages = [[NSMutableArray alloc] init];
                messagesByConversation[@(message.cid)] = conversationMessages;
            }
            
            [conversationMessages addObject:message];
        }
    }
    
    [messagesByConversation enumerateKeysAndObjectsUsingBlock:^(NSNumber *nConversationId, NSArray *messageList, __unused BOOL *stop)
    {
        [[TGDatabase instance] addMessagesToConversation:messageList conversationId:[nConversationId longLongValue] updateConversation:nil dispatch:true countUnread:false];
    }];
    
    [ActionStageInstance() actionCompleted:self.path result:@{@"messagesByConversation": messagesByConversation}];
}

- (void)messagesRequestFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
