#import "TGBridgeCommon.h"
#import "TGBridgeMessage.h"

@interface TGBridgeChat : NSObject <NSCoding>
{
    int64_t _identifier;
    NSTimeInterval _date;
    int32_t _fromUid;
    NSString *_text;
    
    NSArray *_media;
    
    bool _outgoing;
    bool _unread;
    bool _deliveryError;
    TGBridgeMessageDeliveryState _deliveryState;
    
    int32_t _unreadCount;
    
    bool _broadcast;
    
    NSString *_groupTitle;
    NSString *_groupPhotoSmall;
    NSString *_groupPhotoMedium;
    NSString *_groupPhotoBig;
    
    bool _isGroup;
    bool _hasLeftGroup;
    bool _isKickedFromGroup;
    
    bool _isChannel;
    
    NSString *_userName;
    NSString *_about;
    bool _isVerified;
    
    int32_t _participantsCount;
    NSArray *_participants;
}

@property (nonatomic, readonly) int64_t identifier;
@property (nonatomic, readonly) NSTimeInterval date;
@property (nonatomic, readonly) int32_t fromUid;
@property (nonatomic, readonly) NSString *text;

@property (nonatomic, readonly) NSArray *media;

@property (nonatomic, readonly) bool outgoing;
@property (nonatomic, readonly) bool unread;
@property (nonatomic, readonly) bool deliveryError;
@property (nonatomic, readonly) TGBridgeMessageDeliveryState deliveryState;

@property (nonatomic, readonly) int32_t unreadCount;

@property (nonatomic, readonly) bool isBroadcast;

@property (nonatomic, readonly) NSString *groupTitle;
@property (nonatomic, readonly) NSString *groupPhotoSmall;
@property (nonatomic, readonly) NSString *groupPhotoBig;

@property (nonatomic, readonly) bool isGroup;
@property (nonatomic, readonly) bool hasLeftGroup;
@property (nonatomic, readonly) bool isKickedFromGroup;

@property (nonatomic, readonly) bool isChannel;

@property (nonatomic, readonly) NSString *userName;
@property (nonatomic, readonly) NSString *about;
@property (nonatomic, readonly) bool isVerified;

@property (nonatomic, readonly) int32_t participantsCount;
@property (nonatomic, readonly) NSArray *participants;

- (NSIndexSet *)involvedUserIds;
- (NSIndexSet *)participantsUserIds;

@end

extern NSString *const TGBridgeChatKey;
extern NSString *const TGBridgeChatsArrayKey;
