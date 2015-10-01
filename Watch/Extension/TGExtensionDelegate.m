#import "TGExtensionDelegate.h"
#import "TGFileCache.h"
#import "TGBridgeClient.h"

@implementation TGExtensionDelegate

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        TGLog(@"Extension initialization start");
        [TGBridgeClient instance];
        
        _audioCache = [[TGFileCache alloc] initWithName:@"audio" useMemoryCache:false useApplicationGroup:true];
        _audioCache.defaultFileExtension = @"m4a";
        
        _imageCache = [[TGFileCache alloc] initWithName:@"images" useMemoryCache:true];
    }
    return self;
}

- (TGNeoChatsController *)chatsController
{
    return (TGNeoChatsController *)[WKExtension sharedExtension].rootInterfaceController;
}

- (void)applicationDidBecomeActive
{
    [[TGBridgeClient instance] handleDidBecomeActive];
}

- (void)applicationWillResignActive
{
    [[TGBridgeClient instance] handleWillResignActive];
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}

- (void)didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}

+ (instancetype)instance
{
    return (TGExtensionDelegate *)[[WKExtension sharedExtension] delegate];
}

@end
