#import "TGCheckImageStoredActor.h"

#import "ActionStage.h"

#import "TGRemoteImageView.h"

#import "TGDatabase.h"

#import <AssetsLibrary/AssetsLibrary.h>

@implementation TGCheckImageStoredActor

+ (NSString *)genericPath
{
    return @"/tg/checkImageStored/@";
}

- (void)execute:(NSDictionary *)options
{
    NSString *url = [options objectForKey:@"url"];
    NSData *fileData = [options objectForKey:@"data"];
    
    [TGDatabaseInstance() checkIfAssetIsStored:url completion:^(bool stored)
    {
        if (!stored)
        {
            NSData *data = fileData;
            
            if (data == nil)
            {
                NSString *path = [[TGRemoteImageView sharedCache] pathForCachedData:url];
                if (path != nil)
                {
                    data = [[NSData alloc] initWithContentsOfFile:path];
                }
            }
            
            if (data != nil)
            {
                ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
                
                __block __strong ALAssetsLibrary *blockLibrary = assetsLibrary;
                
                [assetsLibrary writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, __unused NSError *error)
                {
                    TGLog(@"Saved to %@", assetURL);
                    
                    blockLibrary = nil;
                    
                    [ActionStageInstance() dispatchOnStageQueue:^
                    {
                        [TGDatabaseInstance() setAssetIsStored:url];
                        
                        [ActionStageInstance() actionCompleted:self.path result:nil];
                    }];
                }];
            }
        }
        else
        {
            [ActionStageInstance() actionCompleted:self.path result:nil];
        }
    }];
}



@end
