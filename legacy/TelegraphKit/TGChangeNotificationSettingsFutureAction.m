#import "TGChangeNotificationSettingsFutureAction.h"

@interface TGChangeNotificationSettingsFutureAction ()
{
    int32_t _muteUntilRaw;
    int32_t _soundIdRaw;
    int32_t _previewTextRaw;
    int8_t _messagesMutedRaw;
}
@end

@implementation TGChangeNotificationSettingsFutureAction

@dynamic muteUntil, soundId, previewText, messagesMuted;

- (id)initWithPeerId:(int64_t)peerId muteUntil:(NSNumber *)muteUntil soundId:(NSNumber *)soundId previewText:(NSNumber *)previewText photoNotificationsEnabled:(bool)photoNotificationsEnabled messagesMuted:(NSNumber *)messagesMuted
{
    self = [super initWithType:TGChangeNotificationSettingsFutureActionType];
    if (self != nil)
    {
        self.uniqueId = peerId;
        
        _muteUntilRaw = muteUntil ? muteUntil.intValue : INT32_MIN;
        _soundIdRaw = soundId ? soundId.intValue : INT32_MIN;
        _previewTextRaw = previewText ? previewText.intValue : INT32_MIN;
        _photoNotificationsEnabled = photoNotificationsEnabled;
        _messagesMutedRaw = messagesMuted ? messagesMuted.unsignedCharValue : INT8_MAX;
    }
    return self;
}

- (NSNumber *)muteUntil
{
    return _muteUntilRaw != INT32_MIN ? @(_muteUntilRaw) : nil;
}

- (NSNumber *)soundId
{
    return _soundIdRaw != INT32_MIN ? @(_soundIdRaw) : nil;
}

- (NSNumber *)previewText
{
    return _previewTextRaw != INT32_MIN ? @(_previewTextRaw) : nil;
}

- (NSNumber *)messagesMuted
{
    return _messagesMutedRaw != INT8_MAX ? @(_messagesMutedRaw) : nil;
}

- (NSData *)serialize
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [data appendBytes:&_muteUntilRaw length:4];
    [data appendBytes:&_soundIdRaw length:4];
    
    int previewText = _previewTextRaw;
    [data appendBytes:&previewText length:4];
    
    uint8_t valuePhotoNotificationsEnabled = _photoNotificationsEnabled ? 1 : 0;
    [data appendBytes:&valuePhotoNotificationsEnabled length:1];
    
    uint8_t valueMessagesMuted = _messagesMutedRaw;
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
    
    action = [[TGChangeNotificationSettingsFutureAction alloc] initWithPeerId:0 muteUntil:muteUntil != INT32_MIN ? @(muteUntil) : nil soundId:soundId != INT32_MIN ? @(soundId) : nil previewText:previewText != INT32_MIN ? @(previewText) : nil photoNotificationsEnabled:valuePhotoNotificationsEnabled != 0 messagesMuted:valueMessagesMuted != INT8_MAX ? @(valueMessagesMuted) : nil];
    
    return action;
}

@end
