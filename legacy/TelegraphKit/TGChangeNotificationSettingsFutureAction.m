#import "TGChangeNotificationSettingsFutureAction.h"

@implementation TGChangeNotificationSettingsFutureAction

- (id)initWithPeerId:(int64_t)peerId muteUntil:(int)muteUntil soundId:(int)soundId previewText:(bool)previewText photoNotificationsEnabled:(bool)photoNotificationsEnabled messagesMuted:(bool)messagesMuted
{
    self = [super initWithType:TGChangeNotificationSettingsFutureActionType];
    if (self != nil)
    {
        self.uniqueId = peerId;
        
        _muteUntil = muteUntil;
        _soundId = soundId;
        _previewText = previewText;
        _photoNotificationsEnabled = photoNotificationsEnabled;
        _messagesMuted = messagesMuted;
    }
    return self;
}

- (NSData *)serialize
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [data appendBytes:&_muteUntil length:4];
    [data appendBytes:&_soundId length:4];
    
    int previewText = _previewText ? 1 : 0;
    [data appendBytes:&previewText length:4];
    
    uint8_t valuePhotoNotificationsEnabled = _photoNotificationsEnabled ? 1 : 0;
    [data appendBytes:&valuePhotoNotificationsEnabled length:1];
    
    uint8_t valueMessagesMuted = _messagesMuted ? 1 : 0;
    [data appendBytes:&valueMessagesMuted length:1];
    
    return data;
}

- (TGFutureAction *)deserialize:(NSData *)data
{
    TGChangeNotificationSettingsFutureAction *action = nil;
    
    int ptr = 0;
    
    int muteUntil = 0;
    [data getBytes:&muteUntil range:NSMakeRange(ptr, 4)];
    ptr += 4;
    
    int soundId = 0;
    [data getBytes:&soundId range:NSMakeRange(ptr, 4)];
    ptr += 4;
    
    int previewText = 0;
    [data getBytes:&previewText range:NSMakeRange(ptr, 4)];
    ptr += 4;
    
    uint8_t valuePhotoNotificationsEnabled = 1;
    if ((int)data.length >= ptr)
    {
        [data getBytes:&valuePhotoNotificationsEnabled range:NSMakeRange(ptr, 1)];
        ptr += 1;
    }
    
    uint8_t valueMessagesMuted = 0;
    if ((int)data.length >= ptr)
    {
        [data getBytes:&valueMessagesMuted range:NSMakeRange(ptr, 1)];
        ptr += 1;
    }
    
    action = [[TGChangeNotificationSettingsFutureAction alloc] initWithPeerId:0 muteUntil:muteUntil soundId:soundId previewText:previewText != 0 photoNotificationsEnabled:valuePhotoNotificationsEnabled != 0 messagesMuted:valueMessagesMuted != 0];
    
    return action;
}

@end
