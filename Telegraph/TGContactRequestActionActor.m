#import "TGContactRequestActionActor.h"

#import "ActionStage.h"

#import "TGTelegraph.h"
#import "TGUser+Telegraph.h"
#import "TGMessage+Telegraph.h"
#import "TGUserDataRequestBuilder.h"
#import "TGDatabase.h"

#import "TGUpdateStateRequestBuilder.h"

#import "TGConversationAddMessagesActor.h"

#import "TLMessage$modernMessage.h"

#import "TLUser$modernUser.h"

@interface TGContactRequestActionActor ()

@property (nonatomic) int uid;

@end

@implementation TGContactRequestActionActor

@synthesize uid = _uid;

+ (NSString *)genericPath
{
    return @"/tg/contacts/requestActor/@/@";
}

- (void)prepare:(NSDictionary *)__unused options
{
    self.requestQueueName = @"messages";
}

- (void)execute:(NSDictionary *)options
{
    NSString *action = [options objectForKey:@"action"];
    NSNumber *nUid = [options objectForKey:@"uid"];
    
    if (action == nil || nUid == nil)
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
        return;
    }
    
    _uid = [nUid intValue];
    
    if ([action isEqualToString:@"requestContact"])
    {
        self.cancelToken = [TGTelegraphInstance doSendContactRequest:_uid actor:self];
    }
    else if ([action isEqualToString:@"acceptContact"])
    {
        self.cancelToken = [TGTelegraphInstance doAcceptContactRequest:_uid actor:self];
    }
    else if ([action isEqualToString:@"declineContact"])
    {
        self.cancelToken = [TGTelegraphInstance doDeclineContactRequest:_uid actor:self];
    }
    else
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
        return;
    }
}

- (void)sendRequestSuccess:(TLcontacts_SentLink *)link
{
    TGUser *user = [[TGUser alloc] initWithTelegraphUserDesc:link.link.user];
    [TGUserDataRequestBuilder executeUserObjectsUpdate:[NSArray arrayWithObject:user]];
    
    int userLink = extractUserLink(link.link);
    [TGUserDataRequestBuilder executeUserLinkUpdates:[[NSArray alloc] initWithObjects:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:((TLUser$modernUser *)link.link.user).n_id], [[NSNumber alloc] initWithInt:userLink], nil], nil]];
    
    if ([link.message isKindOfClass:[TLMessage$modernMessage class]])
    {
        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:(TLMessage$message *)link.message];
        if (message.mid != 0)
        {
            static int messageActionId = 1000000;
            [[[TGConversationAddMessagesActor alloc] initWithPath:[NSString stringWithFormat:@"/tg/addmessage/(%dact)", messageActionId++]] execute:[NSDictionary dictionaryWithObjectsAndKeys:[[NSArray alloc] initWithObjects:message, nil], @"messages", nil]];
        }
    }
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)sendRequestFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)acceptRequestSuccess:(TLcontacts_Link *)link
{
    TGUser *user = [[TGUser alloc] initWithTelegraphUserDesc:link.user];
    [TGUserDataRequestBuilder executeUserObjectsUpdate:[NSArray arrayWithObject:user]];
    
    int userLink = extractUserLink(link);
    [TGUserDataRequestBuilder executeUserLinkUpdates:[[NSArray alloc] initWithObjects:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:((TLUser$modernUser *)link.user).n_id], [[NSNumber alloc] initWithInt:userLink], nil], nil]];
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)acceptRequestFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)declineRequestSuccess:(TLcontacts_Link *)link
{
    TGUser *user = [[TGUser alloc] initWithTelegraphUserDesc:link.user];
    [TGUserDataRequestBuilder executeUserObjectsUpdate:[NSArray arrayWithObject:user]];
    
    int userLink = extractUserLink(link);
    [TGUserDataRequestBuilder executeUserLinkUpdates:[[NSArray alloc] initWithObjects:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:((TLUser$modernUser *)link.user).n_id], [[NSNumber alloc] initWithInt:userLink], nil], nil]];
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)declineRequestFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
