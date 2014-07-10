#import "TGPrivacySettingsRequestActor.h"

#import "TGTelegraph.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGDatabase.h"

#import "TGUpdateStateRequestBuilder.h"

static int cachedPrivacySettingsStateVersion = -1;

@implementation TGPrivacySettingsRequestActor

+ (NSString *)genericPath
{
    return @"/tg/privacySettings/@";
}

- (void)prepare:(NSDictionary *)__unused options
{
    if ([self.path hasSuffix:@"(force)"])
        self.requestQueueName = @"settings";
}

- (void)execute:(NSDictionary *)__unused options
{
    if ([self.path hasSuffix:@"(force)"])
    {
        self.cancelToken = [TGTelegraphInstance doRequestPrivacySettings:self];
    }
    else
    {
        [TGDatabaseInstance() customProperty:@"privacySettings" completion:^(NSData *value)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            bool disableSuggestions = false;
            bool hideContacts = false;
            bool hideLastVisit = false;
            bool hideLocation = false;
            
            if (value != nil)
            {
                NSArray *values = [[[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding] componentsSeparatedByString:@","];
                if (values.count >= 4)
                {
                    disableSuggestions = [[values objectAtIndex:0] intValue] != 0;
                    hideContacts = [[values objectAtIndex:1] intValue] != 0;
                    hideLastVisit = [[values objectAtIndex:2] intValue] != 0;
                    hideLocation = [[values objectAtIndex:3] intValue] != 0;
                }
            }
            
            [dict setObject:[[NSNumber alloc] initWithBool:disableSuggestions] forKey:@"disableSuggestions"];
            [dict setObject:[[NSNumber alloc] initWithBool:hideContacts] forKey:@"hideContacts"];
            [dict setObject:[[NSNumber alloc] initWithBool:hideLastVisit] forKey:@"hideLastVisit"];
            [dict setObject:[[NSNumber alloc] initWithBool:hideLocation] forKey:@"hideLocation"];
            
            [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:dict]];
        }];
        
        if (cachedPrivacySettingsStateVersion < [TGUpdateStateRequestBuilder stateVersion])
        {
            [ActionStageInstance() requestActor:@"/tg/privacySettings/(force)" options:nil watcher:TGTelegraphInstance];
        }
    }
}

- (void)privacySettingsRequestSuccess:(TLGlobalPrivacySettings *)privacySettings
{
    TGChangePrivacySettingsFutureAction *action = (TGChangePrivacySettingsFutureAction *)[TGDatabaseInstance() loadFutureAction:0 type:TGChangePrivacySettingsFutureActionType];
    if (action != nil)
    {
        privacySettings.no_suggestions = action.disableSuggestions;
        privacySettings.hide_contacts = action.hideContacts;
        privacySettings.hide_last_visit = action.hideLastVisit;
        privacySettings.hide_located = action.hideLocation;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:[[NSNumber alloc] initWithBool:privacySettings.no_suggestions] forKey:@"disableSuggestions"];
    [dict setObject:[[NSNumber alloc] initWithBool:privacySettings.hide_contacts] forKey:@"hideContacts"];
    [dict setObject:[[NSNumber alloc] initWithBool:privacySettings.hide_last_visit] forKey:@"hideLastVisit"];
    [dict setObject:[[NSNumber alloc] initWithBool:privacySettings.hide_located] forKey:@"hideLocation"];
    
    cachedPrivacySettingsStateVersion = [TGUpdateStateRequestBuilder stateVersion];
    
    [TGDatabaseInstance() setCustomProperty:@"privacySettings" value:[[[NSString alloc] initWithFormat:@"%d,%d,%d,%d", privacySettings.no_suggestions ? 1 : 0, privacySettings.hide_contacts ? 1 : 0, privacySettings.hide_last_visit ? 1 : 0, privacySettings.hide_located ? 1 : 0] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [ActionStageInstance() dispatchResource:@"/tg/privacySettings" resource:[[SGraphObjectNode alloc] initWithObject:dict]];
    
    [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:dict]];
}

- (void)privacySettingsRequestFailed
{
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

@end
