#import "TGCacheController.h"

#import "TGButtonCollectionItem.h"
#import "TGVariantCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGProgressWindow.h"

#import "TGRemoteImageView.h"

#import "TGActionSheet.h"

#import "TGDatabase.h"

#import "TGStringUtils.h"

#import "TGAlertView.h"

#import "TGAppDelegate.h"

@interface TGCacheController ()
{
    TGProgressWindow *_progressWindow;
    TGVariantCollectionItem *_cacheItem;
}

@end

@implementation TGCacheController

- (NSArray *)keepMediaVariants
{
    NSArray *values = @[//@(1 * 60 * 60 * 24),
                        @(1 * 60 * 60 * 24 * 7),
                        @(1 * 60 * 60 * 24 * 7 * 4),
                        @(INT_MAX)];
    
    NSMutableArray *variants = [[NSMutableArray alloc] init];
    for (NSNumber *nValue in values)
    {
        NSString *title = @"";
        
        if ([nValue intValue] == INT_MAX)
            title = TGLocalized(@"MessageTimer.Forever");
        else
            title = [TGStringUtils stringForMessageTimerSeconds:[nValue intValue]];
        
        [variants addObject:@{@"title": title, @"value": nValue}];
    }
    
    return variants;
}

- (NSString *)keepMediaVariantTitleForSeconds:(int)seconds
{
    for (NSDictionary *record in [self keepMediaVariants])
    {
        if ([record[@"value"] intValue] == seconds)
            return record[@"title"];
    }
    
    return [[NSString alloc] initWithFormat:@"%d seconds", seconds];
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.title = TGLocalized(@"Cache.Title");
        
        int keepMediaSeconds = INT_MAX;
        NSNumber *nKeepMediaSeconds = [[NSUserDefaults standardUserDefaults] objectForKey:@"keepMediaSeconds"];
        if (nKeepMediaSeconds != nil)
            keepMediaSeconds = [nKeepMediaSeconds intValue];
        
        _cacheItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Cache.KeepMedia") action:@selector(keepMediaPressed)];
        _cacheItem.variant = [self keepMediaVariantTitleForSeconds:keepMediaSeconds];
        
        _cacheItem.deselectAutomatically = true;
        
        TGCommentCollectionItem *commentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Cache.Help")];
        
        TGCollectionMenuSection *cacheSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _cacheItem,
            commentItem,
        ]];
        
        UIEdgeInsets topSectionInsets = cacheSection.insets;
        topSectionInsets.top = 32.0f;
        cacheSection.insets = topSectionInsets;
        [self.menuSections addSection:cacheSection];

        TGButtonCollectionItem *clearCacheButton = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Cache.ClearCache") action:@selector(clearCachePressed)];
        clearCacheButton.deselectAutomatically = true;
        TGCollectionMenuSection *clearSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            clearCacheButton
        ]];
        [self.menuSections addSection:clearSection];
    }
    return self;
}

- (void)keepMediaPressed
{
    __weak TGCacheController *weakSelf = self;
    
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    for (NSDictionary *record in [self keepMediaVariants])
    {
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:record[@"title"] action:[[NSString alloc] initWithFormat:@"%@", record[@"value"]]]];
    }
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(__unused id target, NSString *action)
    {
        __strong TGCacheController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
           if (![action isEqualToString:@"cancel"])
           {
               [strongSelf applyKeepMediaSeconds:[action intValue]];
           }
        }
    } target:self] showInView:self.view];
}

- (void)applyKeepMediaSeconds:(int)value
{
    [[NSUserDefaults standardUserDefaults] setObject:@(value) forKey:@"keepMediaSeconds"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_cacheItem setVariant:[self keepMediaVariantTitleForSeconds:value]];
    
    [TGDatabaseInstance() processAndScheduleMediaCleanup];
}

- (void)clearCachePressed
{
    [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Cache.ClearCacheAlert") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
    {
        if (okButtonPressed)
        {
            _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [_progressWindow show:true];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
            {
                [TGDatabaseInstance() clearCachedMedia];
                
                [[TGRemoteImageView sharedCache] clearCache:TGCacheDisk];
                
                NSString *documentsDirectory = [TGAppDelegate documentsPath];
                
                [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"files"] error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"audio"] error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"video"] error:nil];
                
                TGDispatchOnMainThread(^
                {
                    [_progressWindow dismissWithSuccess];
                });
            });
        }
    }] show];
}

@end
