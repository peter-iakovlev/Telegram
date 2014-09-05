#import "TGCacheController.h"

#import "TGButtonCollectionItem.h"

#import "TGProgressWindow.h"

#import "TGRemoteImageView.h"

@interface TGCacheController ()
{
    TGProgressWindow *_progressWindow;
}

@end

@implementation TGCacheController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.title = TGLocalized(@"Cache.Title");
        
        TGButtonCollectionItem *cacheItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Cache.ClearCache") action:@selector(clearCachePressed)];
        cacheItem.deselectAutomatically = true;
        TGCollectionMenuSection *cacheSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            cacheItem
        ]];
        UIEdgeInsets topSectionInsets = cacheSection.insets;
        topSectionInsets.top = 32.0f;
        cacheSection.insets = topSectionInsets;
        [self.menuSections addSection:cacheSection];
    }
    return self;
}

- (void)clearCachePressed
{
    _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [_progressWindow show:true];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        [[TGRemoteImageView sharedCache] clearCache:TGCacheDisk];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"files"] error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"audio"] error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"video"] error:nil];
        
        TGDispatchOnMainThread(^
        {
            [_progressWindow dismissWithSuccess];
        });
    });
}

@end
