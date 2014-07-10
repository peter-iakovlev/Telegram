/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernRemoteWallpaperListActor.h"

#import "ActionStage.h"

#import "TL/TLMetaScheme.h"
#import "TGTelegraph.h"

#import "TGImageInfo+Telegraph.h"

#import "TGRemoteWallpaperInfo.h"

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
            
            TGImageInfo *imageInfo = [[TGImageInfo alloc] initWithTelegraphSizesDescription:concreteWallpaper.sizes];
            
            NSString *thumbnailUri = [imageInfo closestImageUrlWithSize:CGSizeMake(256.0f, 256.0f) resultingSize:NULL];
            NSString *fullscreenUri = [imageInfo closestImageUrlWithSize:CGSizeMake(640.0f, 1136.0f) resultingSize:NULL];
            if (thumbnailUri != nil && fullscreenUri != nil)
            {
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
