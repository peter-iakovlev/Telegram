#import "TGSaveGeocodingResultActor.h"

#import "ActionStage.h"

#import "TGTelegraph.h"

@implementation TGSaveGeocodingResultActor

+ (NSString *)genericPath
{
    return @"/tg/location/savegeocode/@";
}

- (void)execute:(NSDictionary *)options
{
    NSDictionary *components = [options objectForKey:@"components"];
    double latitude = [[options objectForKey:@"latitude"] doubleValue];
    double longitude = [[options objectForKey:@"longitude"] doubleValue];
    
    self.cancelToken = [TGTelegraphInstance doSaveGeocodingResult:latitude longitude:longitude components:components actor:self];
}

- (void)saveGeocodingResultSuccess
{
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)saveGeocodingResultFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
