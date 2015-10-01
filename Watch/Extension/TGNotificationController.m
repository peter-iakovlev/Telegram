#import "TGNotificationController.h"

#import "TGStringUtils.h"
#import "TGLocationUtils.h"
#import "WKInterfaceImage+Signals.h"

#import "TGInputController.h"

#import "TGMessageViewModel.h"

#import "TGBridgeMediaSignals.h"
#import "TGBridgeClient.h"
#import "TGBridgeResponse.h"
#import "TGBridgeChatMessageListSubscription.h"
#import "TGBridgeChatMessageListView.h"
#import "TGBridgeMessage.h"
#import "TGBridgeChat.h"
#import "TGBridgeUser.h"

#import "TGPeerIdAdapter.h"

#import <WatchConnectivity/WatchConnectivity.h>

@interface TGNotificationController()
{
    NSString *_currentAvatarPhoto;
    SMetaDisposable *_disposable;
}
@end

@implementation TGNotificationController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _disposable = [[SMetaDisposable alloc] init];
    }
    return self;
}

-(void)dealloc
{
    [_disposable dispose];
}

- (void)didReceiveLocalNotification:(UILocalNotification *)localNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler
{
    int64_t peerId = [localNotification.userInfo[@"cid"] int64Value];
    int32_t messageId = [localNotification.userInfo[@"mid"] int32Value];
    
    [self processMessageWithId:messageId peerId:peerId defaultText:localNotification.alertBody completion:completionHandler];
}

- (void)didReceiveRemoteNotification:(NSDictionary *)remoteNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler
{
    NSString *fromId = remoteNotification[@"from_id"];
    NSString *chatId = remoteNotification[@"chat_id"];
    NSString *mid = remoteNotification[@"msg_id"];
    
    int64_t peerId = (chatId != nil) ? [chatId integerValue] : [fromId integerValue];
    int32_t messageId = (int32_t)[mid integerValue];
    
    [self processMessageWithId:messageId peerId:peerId defaultText:remoteNotification[@"aps"][@"alert"] completion:completionHandler];
}

- (void)processMessageWithId:(int32_t)messageId peerId:(int64_t)peerId defaultText:(NSString *)defaultText completion:(void (^)(WKUserNotificationInterfaceType))completionHandler
{
    TGBridgeChatMessageSubscription *subscription = [[TGBridgeChatMessageSubscription alloc] initWithPeerId:peerId messageId:messageId];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:subscription];

    SSignal *signal = [[[[TGBridgeClient instance] sendMessageData:data] timeout:3.0 onQueue:[SQueue mainQueue] orSignal:[SSignal fail:nil]] catch:^SSignal *(NSError *error)
    {
        if (error.domain != WCErrorDomain)
            return [SSignal fail:nil];

        SSignal *waitSignal = [[[[[[TGBridgeClient instance] actualReachabilitySignal] filter:^bool(NSNumber *state)
        {
            return state.boolValue;
        }] take:1] timeout:4.0 onQueue:[SQueue mainQueue] orSignal:[SSignal fail:nil]] mapToSignal:^SSignal *(NSNumber *state)
        {
            if (!state.boolValue)
                return [SSignal fail:nil];

            return [[TGBridgeClient instance] sendMessageData:data];
        }];
        
        if (error.code == WCErrorCodeDeliveryFailed || error.code == WCErrorCodeNotReachable)
        {
            return [[[[TGBridgeClient instance] sendMessageData:data] delay:1.5 onQueue:[SQueue mainQueue]] catch:^SSignal *(NSError *error)
            {
                if (error.code == WCErrorCodeNotReachable)
                {
                    return waitSignal;
                }
                return [SSignal fail:nil];
            }];
        }
        
        return [SSignal fail:nil];
    }];
    
    __weak TGNotificationController *weakSelf = self;
    [_disposable setDisposable:[[signal timeout:6.0 onQueue:[SQueue mainQueue] orSignal:[SSignal single:@0]] startWithNext:^(NSData *messageData)
    {
        __strong TGNotificationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if ([messageData isKindOfClass:[NSNumber class]])
        {
            self.messageTextLabel.text = defaultText;
            completionHandler(WKUserNotificationInterfaceTypeCustom);            
        }
        else
        {
            TGBridgeResponse *response = [NSKeyedUnarchiver unarchiveObjectWithData:messageData];
            NSDictionary *message = response.next;
            [strongSelf updateWithMessage:message[TGBridgeMessageKey] users:message[TGBridgeUsersDictionaryKey] chat:message[TGBridgeChatKey] completion:completionHandler];
        }
    } error:^(id error)
    {
        self.messageTextLabel.text = defaultText;
        completionHandler(WKUserNotificationInterfaceTypeCustom);
    } completed:^
    {
        
    }]];
}

- (void)updateWithMessage:(TGBridgeMessage *)message users:(NSDictionary *)users chat:(TGBridgeChat *)chat completion:(void (^)(WKUserNotificationInterfaceType))completionHandler
{
    bool mediaGroupHidden = true;
    bool mapGroupHidden = true;
    bool fileGroupHidden = true;
    bool stickerGroupHidden = true;
    bool captionGroupHidden = true;
    
    TGBridgeForwardedMessageMediaAttachment *forwardAttachment = nil;
    TGBridgeReplyMessageMediaAttachment *replyAttachment = nil;
    NSString *messageText = nil;
    
    __block NSInteger completionCount = 1;
    void (^completionBlock)(void) = ^
    {
        completionCount--;
        if (completionCount == 0)
            completionHandler(WKUserNotificationInterfaceTypeCustom);
    };
    
    for (TGBridgeMediaAttachment *attachment in message.media)
    {
        if ([attachment isKindOfClass:[TGBridgeForwardedMessageMediaAttachment class]])
        {
            forwardAttachment = (TGBridgeForwardedMessageMediaAttachment *)attachment;
        }
        else if ([attachment isKindOfClass:[TGBridgeReplyMessageMediaAttachment class]])
        {
            replyAttachment = (TGBridgeReplyMessageMediaAttachment *)attachment;
        }
        else if ([attachment isKindOfClass:[TGBridgeImageMediaAttachment class]])
        {
            mediaGroupHidden = false;
            
            TGBridgeImageMediaAttachment *imageAttachment = (TGBridgeImageMediaAttachment *)attachment;
            
            if (imageAttachment.caption.length > 0)
            {
                captionGroupHidden = false;
                messageText = imageAttachment.caption;
            }
            
            completionCount++;
            
            CGSize imageSize = CGSizeZero;
            [TGMessageViewModel updateMediaGroup:self.mediaGroup activityIndicator:nil mediaAttachment:imageAttachment currentPhoto:NULL standalone:true margin:1.5f imageSize:&imageSize isVisible:nil completion:completionBlock];
            
            self.mediaGroup.width = imageSize.width;
            self.mediaGroup.height = imageSize.height;
            
            self.durationGroup.hidden = true;
        }
        else if ([attachment isKindOfClass:[TGBridgeVideoMediaAttachment class]])
        {
            mediaGroupHidden = false;
            
            TGBridgeVideoMediaAttachment *videoAttachment = (TGBridgeVideoMediaAttachment *)attachment;
            
            if (videoAttachment.caption.length > 0)
            {
                captionGroupHidden = false;
                messageText = videoAttachment.caption;
            }
            
            completionCount++;
            
            CGSize imageSize = CGSizeZero;
            [TGMessageViewModel updateMediaGroup:self.mediaGroup activityIndicator:nil mediaAttachment:videoAttachment currentPhoto:NULL standalone:true margin:1.5f imageSize:&imageSize isVisible:nil completion:completionBlock];
            
            self.mediaGroup.width = imageSize.width;
            self.mediaGroup.height = imageSize.height;
            
            self.durationGroup.hidden = false;
            
            NSInteger durationMinutes = floor(videoAttachment.duration / 60.0);
            NSInteger durationSeconds = videoAttachment.duration % 60;
            self.durationLabel.text = [NSString stringWithFormat:@"%ld:%02ld", (long)durationMinutes, (long)durationSeconds];
        }
        else if ([attachment isKindOfClass:[TGBridgeDocumentMediaAttachment class]])
        {
            TGBridgeDocumentMediaAttachment *documentAttachment = (TGBridgeDocumentMediaAttachment *)attachment;
            
            if (documentAttachment.isSticker)
            {
                stickerGroupHidden = false;
                
                completionCount++;
                
                [TGStickerViewModel updateWithMessage:message isGroup:false context:nil currentDocumentId:NULL authorLabel:nil imageGroup:self.stickerGroup isVisible:nil completion:completionBlock];
            }
            else
            {
                fileGroupHidden = false;
                
                NSString *extension = [[documentAttachment.fileName pathExtension] lowercaseString];
                if (extension.length == 0)
                    extension = @"file";
                
                self.extensionLabel.text = extension;
                self.titleLabel.text = documentAttachment.fileName;
                self.subtitleLabel.text = [TGStringUtils stringForFileSize:documentAttachment.fileSize precision:2];
                
                self.fileIconGroup.hidden = false;
                self.audioGroup.hidden = true;
                self.venueIcon.hidden = true;
            }
        }
        else if ([attachment isKindOfClass:[TGBridgeAudioMediaAttachment class]])
        {
            fileGroupHidden = false;
            
            TGBridgeAudioMediaAttachment *audioAttachment = (TGBridgeAudioMediaAttachment *)attachment;
            
            self.titleLabel.text = TGLocalized(@"Message.Audio");
            
            NSInteger durationMinutes = floor(audioAttachment.duration / 60.0);
            NSInteger durationSeconds = audioAttachment.duration % 60;
            self.subtitleLabel.text = [NSString stringWithFormat:@"%ld:%02ld", (long)durationMinutes, (long)durationSeconds];
            
            self.audioGroup.hidden = false;
            self.fileIconGroup.hidden = true;
            self.venueIcon.hidden = true;
        }
        else if ([attachment isKindOfClass:[TGBridgeLocationMediaAttachment class]])
        {
            mapGroupHidden = false;
            
            TGBridgeLocationMediaAttachment *locationAttachment = (TGBridgeLocationMediaAttachment *)attachment;
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([TGLocationUtils adjustGMapLatitude:locationAttachment.latitude withPixelOffset:-10 zoom:15], locationAttachment.longitude);
            self.map.region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.003, 0.003));
            self.map.centerPinCoordinate = CLLocationCoordinate2DMake(locationAttachment.latitude, locationAttachment.longitude);
            
            if (locationAttachment.venue != nil)
            {
                fileGroupHidden = false;
                
                self.titleLabel.text = locationAttachment.venue.title;
                self.subtitleLabel.text = locationAttachment.venue.address;
            }
            
            self.audioGroup.hidden = true;
            self.fileIconGroup.hidden = true;
            self.venueIcon.hidden = false;
        }
        else if ([attachment isKindOfClass:[TGBridgeContactMediaAttachment class]])
        {
            fileGroupHidden = false;
            
            TGBridgeContactMediaAttachment *contactAttachment = (TGBridgeContactMediaAttachment *)attachment;
            
            self.audioGroup.hidden = true;
            self.fileIconGroup.hidden = true;
            self.venueIcon.hidden = true;
            
            self.titleLabel.text = [contactAttachment displayName];
            self.subtitleLabel.text = contactAttachment.prettyPhoneNumber;
        }
    }
    
    if (messageText == nil)
        messageText = message.text;
    
    [TGMessageViewModel updateForwardHeaderGroup:self.forwardHeaderGroup titleLabel:self.forwardTitleLabel fromLabel:self.forwardFromLabel forwardAttachment:forwardAttachment textColor:[UIColor blackColor]];
    
    if (replyAttachment != nil)
        completionCount++;
    
    [TGMessageViewModel updateReplyHeaderGroup:self.replyHeaderGroup authorLabel:self.replyAuthorNameLabel imageGroup:self.replyHeaderImageGroup textLabel:self.replyMessageTextLabel titleColor:[UIColor blackColor] subtitleColor:[UIColor hexColor:0x7e7e81] replyAttachment:replyAttachment currentReplyPhoto:NULL isVisible:nil completion:completionBlock];
    
    self.mediaGroup.hidden = mediaGroupHidden;
    self.mapGroup.hidden = mapGroupHidden;
    self.fileGroup.hidden = fileGroupHidden;
    self.captionGroup.hidden = captionGroupHidden;
    self.stickerGroup.hidden = stickerGroupHidden;
    self.stickerWrapperGroup.hidden = stickerGroupHidden;
    
    self.wrapperGroup.hidden = (self.mediaGroup.hidden && self.mapGroup.hidden && self.fileGroup.hidden && self.stickerGroup.hidden);
    
    if (chat.isGroup)
    {
        self.chatTitleLabel.text = chat.groupTitle;
        self.chatTitleLabel.hidden = false;
    }
    
    self.nameLabel.hidden = false;
    if (chat.isChannel)
        self.nameLabel.text = chat.groupTitle;
    else
        self.nameLabel.text = [users[@(message.fromUid)] displayName];
    
    self.messageTextLabel.hidden = (messageText.length == 0);
    if (!self.messageTextLabel.hidden)
        self.messageTextLabel.text = messageText;
    
    completionBlock();
}

- (NSArray<NSString *> *)suggestionsForResponseToActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)localNotification inputLanguage:(NSString *)inputLanguage
{
    return [TGInputController suggestionsForText:nil];
}

- (NSArray<NSString *> *)suggestionsForResponseToActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)remoteNotification inputLanguage:(NSString *)inputLanguage
{
    return [TGInputController suggestionsForText:nil];
}

@end
