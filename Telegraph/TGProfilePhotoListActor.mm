#import "TGProfilePhotoListActor.h"

#import "ActionStage.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"

#import "TGUserDataRequestBuilder.h"

#import "TGUpdateStateRequestBuilder.h"

#import "TGImageMediaAttachment+Telegraph.h"

#import <map>

@interface TGProfilePhotoListActor ()

@property (nonatomic) int64_t peerId;

@end

@implementation TGProfilePhotoListActor

+ (NSString *)genericPath
{
    return @"/tg/profilePhotos/@";
}

- (void)execute:(NSDictionary *)__unused options
{
    _peerId = [options[@"peerId"] longLongValue];
    
    if (_peerId == 0)
        [ActionStageInstance() actionFailed:self.path reason:-1];
    else
    {
        if ([self.path hasSuffix:@"force)"])
        {
            self.cancelToken = [TGTelegraphInstance doRequestPeerProfilePhotoList:_peerId actor:self];
        }
        else
        {
            [TGDatabaseInstance() loadPeerProfilePhotos:_peerId completion:^(NSArray *photosArray)
            {
                [ActionStageInstance() dispatchOnStageQueue:^
                {
                    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/profilePhotos/(%lld,force)", _peerId] options:@{@"peerId": @(_peerId)} flags:0 watcher:TGTelegraphInstance];
                    
                    [ActionStageInstance() actionCompleted:self.path result:photosArray];
                }];
            }];
        }
    }
}

- (void)photoListRequestSuccess:(TLphotos_Photos *)result
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [TGUserDataRequestBuilder executeUserDataUpdate:result.users];
    
    for (TLPhoto *photoDesc in result.photos)
    {
        TGImageMediaAttachment *imageAttachment = [[TGImageMediaAttachment alloc] initWithTelegraphDesc:photoDesc];
        if (imageAttachment != nil)
            [array addObject:imageAttachment];
    }
    
    [TGDatabaseInstance() storePeerProfilePhotos:_peerId photosArray:array append:false];
    
    if ([self.path hasSuffix:@"force)"])
        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/profilePhotos/(%lld)", _peerId] resource:array];
    
    [ActionStageInstance() actionCompleted:self.path result:array];
}

- (void)photoListRequestFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
