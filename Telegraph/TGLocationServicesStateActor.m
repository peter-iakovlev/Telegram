#import "TGLocationServicesStateActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import <CoreLocation/CoreLocation.h>

@interface TGLocationServicesStateActor ()

@property (nonatomic) bool dispatchResult;

@end

@implementation TGLocationServicesStateActor

@synthesize dispatchResult = _dispatchResult;

+ (NSString *)genericPath
{
    return @"/tg/locationServicesState/@";
}

- (void)execute:(NSDictionary *)options
{
    _dispatchResult = [[options objectForKey:@"dispatch"] boolValue];
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        bool enabled = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized;
        bool dispatch = _dispatchResult;
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            if (dispatch)
            {
                [ActionStageInstance() dispatchResource:@"/tg/locationServicesState" resource:[[SGraphObjectNode alloc] initWithObject:[[NSNumber alloc] initWithBool:enabled]]];
            }
            
            [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:[[NSNumber alloc] initWithBool:enabled]]];
        }];
    });
}

@end
