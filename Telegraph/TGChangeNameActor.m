#import "TGChangeNameActor.h"

#import "ActionStage.h"

#import "TGTelegraph.h"

#import "TGUserDataRequestBuilder.h"

@implementation TGChangeNameActor

@synthesize currentFirstName = _currentFirstName;
@synthesize currentLastName = _currentLastName;

+ (NSString *)genericPath
{
    return @"/tg/changeUserName/@";
}

- (void)execute:(NSDictionary *)options
{
    _currentFirstName = [options objectForKey:@"firstName"];
    _currentLastName = [options objectForKey:@"lastName"];
    
    self.cancelToken = [TGTelegraphInstance doChangeName:_currentFirstName lastName:_currentLastName actor:self];
}

- (void)changeNameSuccess:(TLUser *)user
{
    [TGUserDataRequestBuilder executeUserDataUpdate:[[NSArray alloc] initWithObjects:user, nil]];
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)changeNameFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
