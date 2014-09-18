#import "TGChangePrivacySettingsFutureAction.h"

@implementation TGChangePrivacySettingsFutureAction

@synthesize disableSuggestions = _disableSuggestions;
@synthesize hideContacts = _hideContacts;
@synthesize hideLastVisit = _hideLastVisit;
@synthesize hideLocation = _hideLocation;

- (id)initWithDisableSuggestions:(bool)disableSuggestions hideContacts:(bool)hideContacts hideLastVisit:(bool)hideLastVisit hideLocation:(bool)hideLocation
{
    self = [super initWithType:TGChangePrivacySettingsFutureActionType];
    if (self != nil)
    {
        _disableSuggestions = disableSuggestions;
        _hideContacts = hideContacts;
        _hideLastVisit = hideLastVisit;
        _hideLocation = hideLocation;
    }
    return self;
}

- (NSData *)serialize
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    int disableSuggestions = _disableSuggestions ? 1 : 0;
    int hideContacts = _hideContacts ? 1 : 0;
    int hideLastVisit = _hideLastVisit ? 1 : 0;
    int hideLocation = _hideLocation ? 1 : 0;
    
    [data appendBytes:&disableSuggestions length:4];
    [data appendBytes:&hideContacts length:4];
    [data appendBytes:&hideLastVisit length:4];
    [data appendBytes:&hideLocation length:4];
    
    return data;
}

- (TGFutureAction *)deserialize:(NSData *)data
{
    TGChangePrivacySettingsFutureAction *action = nil;
    
    int ptr = 0;
    
    int disableSuggestions = 0;
    [data getBytes:&disableSuggestions range:NSMakeRange(ptr, 4)];
    ptr += 4;
    
    int hideContacts = 0;
    [data getBytes:&hideContacts range:NSMakeRange(ptr, 4)];
    ptr += 4;
    
    int hideLastVisit = 0;
    [data getBytes:&hideLastVisit range:NSMakeRange(ptr, 4)];
    ptr += 4;
    
    int hideLocation = 0;
    [data getBytes:&hideLocation range:NSMakeRange(ptr, 4)];
    ptr += 4;
    
    action = [[TGChangePrivacySettingsFutureAction alloc] initWithDisableSuggestions:disableSuggestions hideContacts:hideContacts hideLastVisit:hideLastVisit hideLocation:hideLocation];
    
    return action;
}

@end
