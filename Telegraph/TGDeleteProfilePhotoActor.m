#import "TGDeleteProfilePhotoActor.h"

#import "ActionStage.h"

#import "TGDatabase.h"

#import "TGTelegraph.h"

@implementation TGDeleteProfilePhotoActor

+ (NSString *)genericPath
{
    return @"/tg/deleteProfilePhoto/@";
}

- (void)execute:(NSDictionary *)options
{
    int64_t imageId = [[options objectForKey:@"imageId"] longLongValue];
    int64_t accessHash = [options[@"accessHash"] longLongValue];
    
    if (imageId == 0 || accessHash == 0)
    {
        TGLog(@"***** %@: imageId and accessHash must be non-zero", self.path);
        
        [ActionStageInstance() actionFailed:self.path reason:-1];
    }
    else
    {
        [TGDatabaseInstance() deletePeerProfilePhotos:TGTelegraphInstance.clientUserId imageIds:@[@(imageId)]];
        [TGDatabaseInstance() storeFutureActions:[[NSArray alloc] initWithObjects:[[TGDeleteProfilePhotoFutureAction alloc] initWithImageId:imageId accessHash:accessHash], nil]];
        
        [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(other)" options:nil watcher:TGTelegraphInstance];
        
        [ActionStageInstance() actionCompleted:self.path result:nil];
    }
}

@end
