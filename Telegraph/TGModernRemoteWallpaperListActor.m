/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernRemoteWallpaperListActor.h"

#import <LegacyComponents/ActionStage.h>

#import "TL/TLMetaScheme.h"
#import "TGTelegraph.h"

#import "TGImageInfo+Telegraph.h"
#import "TGMediaOriginInfo+Telegraph.h"

#import <LegacyComponents/TGRemoteWallpaperInfo.h>

static bool alreadyCachedList = false;

@implementation TGModernRemoteWallpaperListActor

+ (NSString *)genericPath
{
    return @"/tg/remoteWallpapers/@";
}

+ (NSArray *)cachedList
{
    NSMutableArray *wallpaperInfos = [[NSMutableArray alloc] init];
    
    NSArray *list = [[NSUserDefaults standardUserDefaults] objectForKey:@"TG_remoteWallpaperList"];
    if (list != nil)
    {
        for (NSDictionary *dict in list)
        {
            TGWallpaperInfo *wallpaperInfo = [TGWallpaperInfo infoWithDictionary:dict];
            if (wallpaperInfo != nil)
                [wallpaperInfos addObject:wallpaperInfo];
        }
    }
    
    return wallpaperInfos;
}

+ (void)cacheList:(NSArray *)wallpaperInfos
{
    TGDispatchOnMainThread(^
    {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        
        for (TGWallpaperInfo *wallpaperInfo in wallpaperInfos)
        {
            NSDictionary *dict = [wallpaperInfo infoDictionary];
            if (dict != nil)
                [list addObject:dict];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:list forKey:@"TG_remoteWallpaperList"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

- (void)execute:(NSDictionary *)__unused options
{
    if (alreadyCachedList)
        [ActionStageInstance() actionFailed:self.path reason:-1];
    else
        self.cancelToken = [TGTelegraphInstance doRequestWallpaperList:(TGWallpaperListRequestActor *)self];
}

- (void)wallpaperListRequestSuccess:(NSArray *)wallpaperList
{
    NSMutableArray *wallpaperInfos = [[NSMutableArray alloc] init];
    
    for (id item in wallpaperList)
    {
        if ([item isKindOfClass:[TLWallPaper$wallPaper class]])
        {
            TLWallPaper$wallPaper *concreteWallpaper = item;
            
            TGMediaOriginInfo *origin = [TGMediaOriginInfo mediaOriginInfoForWallpaper:concreteWallpaper];
            TGImageInfo *imageInfo = [[TGImageInfo alloc] initWithTelegraphSizesDescription:concreteWallpaper.sizes];
            
            NSString *thumbnailUri = [imageInfo closestImageUrlWithSize:CGSizeMake(256.0f, 256.0f) resultingSize:NULL];
            
            CGSize fullscreenSize = TGScreenScaling() > 2 ? CGSizeMake(1080, 1920) : CGSizeMake(640.0f, 1136.0f);
            NSString *fullscreenUri = [imageInfo closestImageUrlWithSize:fullscreenSize resultingSize:NULL];
            if (thumbnailUri != nil && fullscreenUri != nil)
            {
                int64_t volumeId = 0;
                int fileId = 0;
                int64_t secret = 0;
                int datacenterId = 0;
                
                NSString *fileReference = nil;
                if (extractFileUrlComponents(thumbnailUri, &datacenterId, &volumeId, &fileId, &secret) && datacenterId != 0) {
                    fileReference = [[origin fileReferenceForVolumeId:volumeId localId:fileId] stringByEncodingInHex];
                    if (fileReference.length > 0)
                        thumbnailUri = [thumbnailUri stringByAppendingFormat:@"_%@", fileReference];
                }
                
                if (extractFileUrlComponents(fullscreenUri, &datacenterId, &volumeId, &fileId, &secret) && datacenterId != 0) {
                    fileReference = [[origin fileReferenceForVolumeId:volumeId localId:fileId] stringByEncodingInHex];
                    if (fileReference.length > 0)
                        fullscreenUri = [fullscreenUri stringByAppendingFormat:@"_%@", fileReference];
                }
                
                    
                TGRemoteWallpaperInfo *wallpaperInfo = [[TGRemoteWallpaperInfo alloc] initWithRemoteId:concreteWallpaper.n_id thumbnailUri:thumbnailUri fullscreenUri:fullscreenUri tintColor:concreteWallpaper.color];
                [wallpaperInfos addObject:wallpaperInfo];
            }
        }
    }
    
    [TGModernRemoteWallpaperListActor cacheList:wallpaperInfos];
    alreadyCachedList = true;
    
    [ActionStageInstance() actionCompleted:self.path result:@{@"wallpaperInfos": wallpaperInfos}];
}

- (void)wallpaperListRequestFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
