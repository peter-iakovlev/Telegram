#import "TGWidgetSync.h"
#import <NotificationCenter/NotificationCenter.h>

#import "TGAppDelegate.h"
#import "TGTelegraph.h"

NSString *const TGWidgetSyncIdentifier = @"org.telegram.WidgetUpdate";

@implementation TGWidgetSync

#pragma mark - 

+ (void)setUsers:(NSArray *)users
{
    if (users == nil)
        users = [[NSArray alloc] init];
    
    bool hasContent = users.count > 0;
    
    NSDictionary *dict = @{ @"users": users, @"clientUserId": @(TGTelegraphInstance.clientUserId) };
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    [self storeWidgetData:data];

    [self setHasContent:hasContent];
}

#pragma mark - File

+ (NSString *)filePath
{
    return [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"widget.data"];
}

+ (void)storeWidgetData:(NSData *)data
{
    if (![data writeToFile:[self filePath] atomically:true])
        TGLog(@"***** TGWidgetSync couldn't write to file");
}

+ (void)clearWidgetData
{
    [[NSFileManager defaultManager] removeItemAtPath:[self filePath] error:NULL];
    [self setHasContent:false];
}

#pragma mark - 

+ (void)setHasContent:(bool)hasContent
{
    NSString *bundleIdentifier = [NSString stringWithFormat:@"%@.Widget", [[NSBundle mainBundle] bundleIdentifier]];
    [[NCWidgetController widgetController] setHasContent:hasContent forWidgetWithBundleIdentifier:bundleIdentifier];
}

@end
