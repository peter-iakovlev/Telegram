#import "TGChangePrivacySettingsActor.h"

#import "ActionStage.h"

#import "TGDatabase.h"

#import "TGTelegraph.h"

#import "TGChangePrivacySettingsFutureAction.h"

@implementation TGChangePrivacySettingsActor

+ (NSString *)genericPath
{
    return @"/tg/changePrivacySettings/@";
}

- (void)execute:(NSDictionary *)options
{
    [TGDatabaseInstance() customProperty:@"privacySettings" completion:^(NSData *value)
    {
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
        
        if ([options objectForKey:@"disableSuggestions"] != nil)
            disableSuggestions = [[options objectForKey:@"disableSuggestions"] boolValue];
        if ([options objectForKey:@"hideContacts"] != nil)
            hideContacts = [[options objectForKey:@"hideContacts"] boolValue];
        if ([options objectForKey:@"hideLastVisit"] != nil)
            hideLastVisit = [[options objectForKey:@"hideLastVisit"] boolValue];
        if ([options objectForKey:@"hideLocation"] != nil)
            hideLocation = [[options objectForKey:@"hideLocation"] boolValue];
        
        [TGDatabaseInstance() setCustomProperty:@"privacySettings" value:[[[NSString alloc] initWithFormat:@"%d,%d,%d,%d", disableSuggestions ? 1 : 0, hideContacts ? 1 : 0, hideLastVisit ? 1 : 0, hideLocation ? 1 : 0] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            [TGDatabaseInstance() storeFutureActions:[NSArray arrayWithObject:[[TGChangePrivacySettingsFutureAction alloc] initWithDisableSuggestions:disableSuggestions hideContacts:hideContacts hideLastVisit:hideLastVisit hideLocation:hideLocation]]];
            
            [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(settings)" options:nil watcher:TGTelegraphInstance];
        }];
    }];
}

@end
