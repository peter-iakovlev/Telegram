#import "TGBridgeRemoteHandler.h"
#import "TGBridgeRemoteSubscription.h"

#import "TGInterfaceManager.h"
#import "TGModernConversationController.h"

#import "TGAlertView.h"

@implementation TGBridgeRemoteHandler

+ (SSignal *)handlingSignalForSubscription:(TGBridgeSubscription *)subscription server:(TGBridgeServer *)__unused server
{
    if ([subscription isKindOfClass:[TGBridgeRemoteSubscription class]])
    {
        TGDispatchOnMainThread(^
        {
            TGBridgeRemoteSubscription *remoteSubscription = (TGBridgeRemoteSubscription *)subscription;
            
            if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
                notification.alertBody = TGLocalized(@"WatchRemote.NotificationText");
                notification.category = @"wr";
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.userInfo = @{ @"peerId": @(remoteSubscription.peerId),
                                           @"mid": @(remoteSubscription.messageId),
                                           @"type": @(remoteSubscription.type),
                                           @"autoPlay": @(remoteSubscription.autoPlay) };
                
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
            else
            {
                TGModernConversationController *controller = [[TGInterfaceManager instance] currentControllerWithPeerId:remoteSubscription.peerId];
                if (controller != nil)
                {
                    [self navigateToPeerId:remoteSubscription.peerId messageId:remoteSubscription.messageId startMedia:remoteSubscription.autoPlay];
                }
                else
                {
                    [[[TGAlertView alloc] initWithTitle:TGLocalized(@"WatchRemote.AlertTitle") message:TGLocalized(@"WatchRemote.AlertText") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"WatchRemote.AlertOpen") completionBlock:^(bool okButtonPressed)
                    {
                        if (okButtonPressed)
                        {
                            [self navigateToPeerId:remoteSubscription.peerId messageId:remoteSubscription.messageId startMedia:remoteSubscription.autoPlay];
                        }
                    }] show];
                }
            }
        });
        
        return [SSignal complete];
    }

    return [SSignal fail:nil];
}

+ (void)navigateToPeerId:(int64_t)peerId messageId:(int32_t)messageId startMedia:(bool)startMedia
{
    TGModernConversationController *controller = [[TGInterfaceManager instance] currentControllerWithPeerId:peerId];
    if (controller != nil)
    {
        [controller scrollToMessage:messageId sourceMessageId:0 animated:true];
        if (startMedia)
            [controller openMediaFromMessage:messageId instant:false];
    }
    else
    {
        [[TGInterfaceManager instance] navigateToConversationWithId:peerId conversation:nil performActions:nil atMessage:@{ @"mid": @(messageId) } clearStack:true openKeyboard:false canOpenKeyboardWhileInTransition:false animated:true];
        controller = [[TGInterfaceManager instance] currentControllerWithPeerId:peerId];
        
        if (startMedia)
        {
            TGDispatchAfter(0.8f, dispatch_get_main_queue(), ^
            {
                [controller openMediaFromMessage:messageId instant:false];
            });
        }
    }
}

+ (void)handleLocalNotification:(NSDictionary *)userInfo
{
    int64_t peerId = [userInfo[@"peerId"] int64Value];
    int32_t messageId = [userInfo[@"mid"] int32Value];
    //int32_t type = [userInfo[@"type"] int32Value];
    bool autoPlay = [userInfo[@"autoPlay"] boolValue];
    
    TGDispatchAfter(0.8f, dispatch_get_main_queue(), ^
    {
        [self navigateToPeerId:peerId messageId:messageId startMedia:autoPlay];
    });
}

+ (NSArray *)handledSubscriptions
{
    return @[ [TGBridgeRemoteSubscription class] ];
}

@end
