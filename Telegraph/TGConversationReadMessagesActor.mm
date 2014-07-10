#import "TGConversationReadMessagesActor.h"

#import "ActionStage.h"
#import "SGraphNode.h"
#import "SGraphObjectNode.h"

#import "TGTelegraph.h"

#import "TGDatabase.h"

#import "TGSharedPtrWrapper.h"

#include <set>

@implementation TGConversationReadMessagesActor

+ (NSString *)genericPath
{
    return @"/tg/readmessages/@";
}

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        self.requestQueueName = @"messages";
        self.cancelTimeout = 0;
    }
    return self;
}

- (void)execute:(NSDictionary *)options
{
    NSArray *midList = [options objectForKey:@"mids"];
    if (midList == nil)
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
    }
    
    std::tr1::shared_ptr<std::set<int> > mids(new std::set<int>());
    for (NSNumber *nMid in midList)
    {
        mids->insert([nMid intValue]);
    }
    
    [TGDatabaseInstance() markMessagesAsRead:midList];
    
    TGSharedPtrWrapper *ptrWrapper = [[TGSharedPtrWrapper alloc] init];
    [ptrWrapper setPtr:mids];
    
    [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/conversation/*/readmessages"] resource:[[SGraphObjectNode alloc] initWithObject:ptrWrapper]];
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)cancel
{
    [super cancel];
}

@end
