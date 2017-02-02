#import "TGUserDataRequestBuilder.h"

#import "ActionStage.h"

#import "TGTelegraph.h"

#import "TGUser+Telegraph.h"
#import "TGDatabase.h"

#import "TGUserNode.h"

#import "TGContactListRequestBuilder.h"

#import "TGAccountSettings.h"
#import "TGAccountSettingsActor.h"

#import "TGStringUtils.h"

@implementation TGUserDataRequestBuilder

+ (NSString *)genericPath
{
    return @"/tg/users/@";
}

+ (void)executeUserLinkUpdates:(NSArray *)usersLinks
{
    for (NSArray *record in usersLinks)
    {
        int uid = [[record objectAtIndex:0] intValue];
        int userLink = [[record objectAtIndex:1] intValue];
        
        if ([TGDatabaseInstance() loadUserLink:uid outdated:NULL] != userLink)
        {
            [TGDatabaseInstance() storeUserLink:uid link:userLink];
            [TGTelegraphInstance dispatchUserLinkChanged:uid link:userLink];
        }
        else
        {
            [TGDatabaseInstance() storeUserLink:uid link:userLink];
        }
        
        if (uid != TGTelegraphInstance.clientUserId)
        {
            if (((userLink & TGUserLinkForeignMutual) || (userLink & TGUserLinkMyContact)))
            {
                if (![TGDatabaseInstance() uidIsRemoteContact:uid])
                {
                    TGUser *user = [TGDatabaseInstance() loadUser:uid];
                    if (user.phoneNumber != nil && user.phoneNumber.length != 0)
                    {
                        static int actionId = 0;
                        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/synchronizeContacts/(%d,importLink)", actionId++] options:[NSDictionary dictionaryWithObjectsAndKeys:user, @"user", nil] watcher:TGTelegraphInstance];
                    }
                }
            }
            else if ((userLink & TGUserLinkKnown) && !(userLink & TGUserLinkMyContact))
            {
                if ([TGDatabaseInstance() uidIsRemoteContact:uid])
                {
                    static int actionId = 0;
                    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/synchronizeContacts/(%d,breakLink)", actionId++] options:[NSDictionary dictionaryWithObjectsAndKeys:[[NSNumber alloc] initWithInt:uid], @"uid", nil] watcher:TGTelegraphInstance];
                }
            }
        }
    }
}

+ (void)executeUserObjectsUpdate:(NSArray *)userObjects
{
    NSMutableArray *storeUsers = [[NSMutableArray alloc] init];
    
    NSMutableArray *updateUsers = [[NSMutableArray alloc] init];
    NSMutableArray *updateUserChanges = [[NSMutableArray alloc] init];
    
    for (TGUser *user in userObjects)
    {
        TGUser *originalUser = [[TGDatabase instance] loadUser:user.uid];
        
        int difference = [originalUser differenceFromUser:user];
        if (originalUser == nil || difference != 0)
        {
            TGUser *updatedUser = user;
            if (originalUser != nil)
            {
                if (!TGStringCompare(originalUser.phoneNumber, user.phoneNumber) && user.phoneNumber.length != 0 && [TGDatabaseInstance() uidIsRemoteContact:user.uid])
                {
                    TGPhonebookContact *phonebookContact = [TGDatabaseInstance() phonebookContactByPhoneId:phoneMatchHash(originalUser.phoneNumber)];
                    TGPhonebookContact *newPhonebookContact = [TGDatabaseInstance() phonebookContactByPhoneId:phoneMatchHash(user.phoneNumber)];
                    if (phonebookContact != nil && newPhonebookContact == nil)
                    {
                        [[TGSynchronizeContactsManager instance] scheduleContactPhoneAddition:user.uid];
                        static int actionId = 0;
                        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/synchronizeContacts/(%dappend,appendPhone)", actionId++] options:[NSDictionary dictionaryWithObjectsAndKeys:[[NSNumber alloc] initWithInt:user.uid], @"uid", user.phoneNumber, @"phoneNumber", @(phonebookContact.nativeId), @"nativeId", nil] watcher:TGTelegraphInstance];
                    }
                }
                
                if (user.minimalRepresentation) {
                    updatedUser = [user copy];
                    updatedUser.phoneNumberHash = originalUser.phoneNumberHash;
                    updatedUser.userName = originalUser.userName;
                    updatedUser.presence = originalUser.presence;
                    updatedUser.firstName = originalUser.firstName;
                    updatedUser.lastName = originalUser.lastName;
                    updatedUser.phoneNumber = originalUser.phoneNumber;
                    updatedUser.phonebookFirstName = originalUser.phonebookFirstName;
                    updatedUser.phonebookLastName = originalUser.phonebookLastName;
                }
                
                [updateUsers addObject:updatedUser];
                [updateUserChanges addObject:[[NSNumber alloc] initWithInt:[updatedUser differenceFromUser:originalUser]]];
            }
            
            [storeUsers addObject:updatedUser];
        }
    }
    
    if (storeUsers.count != 0)
        [[TGDatabase instance] storeUsers:storeUsers];
    
    if (updateUsers.count != 0)
    {
        int count = (int)updateUsers.count;
        for (int i = 0; i < count; i++)
        {
            [TGTelegraphInstance dispatchUserDataChanges:[updateUsers objectAtIndex:i] changes:[[updateUserChanges objectAtIndex:i] intValue]];
        }
    }
}

+ (void)executeUserDataUpdate:(NSArray *)users
{
    NSMutableArray *userObjects = [[NSMutableArray alloc] init];
    for (TLUser *userDesc in users)
    {
        TGUser *user = [[TGUser alloc] initWithTelegraphUserDesc:userDesc];
        if (user != nil)
            [userObjects addObject:user];
    }
    
    [TGUserDataRequestBuilder executeUserObjectsUpdate:userObjects];
}

- (void)execute:(NSDictionary *)options
{
    NSArray *downloadedUserData = [options objectForKey:@"downloadedUserData"];
    if (downloadedUserData != nil)
    {
        [TGUserDataRequestBuilder executeUserDataUpdate:downloadedUserData];
        
        // In this case the actor was explicitly invoked, thus we don't need to call nodeRetrieved
    }
    else
    {
        NSString *userIdString = [self.path substringWithRange:NSMakeRange(11, self.path.length - 11 - 1)];
        int uid = [userIdString intValue];
        if (![[NSString stringWithFormat:@"%d", uid] isEqualToString:userIdString])
        {
            [ActionStageInstance() nodeRetrieveFailed:self.path];
            return;
        }
        
        TGUser *user = [[TGDatabase instance] loadUser:uid];
        if (user != nil)
        {
            [ActionStageInstance() nodeRetrieved:self.path node:[[TGUserNode alloc] initWithUser:user]];
            return;
        }
        
        self.cancelToken = [TGTelegraphInstance doRequestUserData:uid requestBuilder:self];
    }
}
         
- (void)userDataRequestSuccess:(NSArray *)users
{   
    [TGUserDataRequestBuilder executeUserDataUpdate:users];
    
    NSString *userIdString = [self.path substringWithRange:NSMakeRange(11, self.path.length - 11 - 1)];
    int uid = [userIdString intValue];
    if (![[NSString stringWithFormat:@"%d", uid] isEqualToString:userIdString])
    {
        [ActionStageInstance() nodeRetrieveFailed:self.path];
        return;
    }
    
    TGUser *user = [[TGDatabase instance] loadUser:uid];
    if (user != nil)
    {
        [ActionStageInstance() nodeRetrieved:self.path node:[[TGUserNode alloc] initWithUser:user]];
        return;
    }
    else
    {
        [ActionStageInstance() nodeRetrieveFailed:self.path];
    }
}

- (void)userDataRequestFailed
{
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

- (void)cancel
{
    if (self.cancelToken != nil)
    {
        [TGTelegraphInstance cancelRequestByToken:self.cancelToken];
        self.cancelToken = nil;
    }
    
    [super cancel];
}

@end
