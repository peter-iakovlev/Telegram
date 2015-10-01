#import "TGNeoRenderableViewModel.h"

@class TGBridgeMessage;
@class TGBridgeUser;
@class TGBridgeContext;

@interface TGNeoMessageViewModel : TGNeoRenderableViewModel

@property (nonatomic, readonly) int32_t identifier;
@property (nonatomic, readonly) NSDictionary *additionalLayout;
@property (nonatomic, assign) bool showBubble;

- (instancetype)initWithMessage:(TGBridgeMessage *)message users:(NSDictionary *)users context:(TGBridgeContext *)context;

- (void)addAdditionalLayout:(NSDictionary *)layout withKey:(NSString *)key;

+ (TGNeoMessageViewModel *)viewModelForMessage:(TGBridgeMessage *)message context:(TGBridgeContext *)context;

+ (TGNeoMessageViewModel *)cachedViewModel;

@end

extern NSString *const TGNeoContentInset;

extern NSString *const TGNeoMessageHeaderGroup;
extern NSString *const TGNeoMessageReplyImageGroup;
extern NSString *const TGNeoMessageReplyMediaAttachment;

extern NSString *const TGNeoMessageMediaGroup;
extern NSString *const TGNeoMessageMediaImage;
extern NSString *const TGNeoMessageMediaImageAttachment;
extern NSString *const TGNeoMessageMediaImageSpinner;
extern NSString *const TGNeoMessageMediaPlayButton;
extern NSString *const TGNeoMessageMediaSize;
extern NSString *const TGNeoMessageMediaMap;
extern NSString *const TGNeoMessageMediaMapSize;
extern NSString *const TGNeoMessageMediaMapCoordinate;

extern NSString *const TGNeoMessageMetaGroup;
extern NSString *const TGNeoMessageAvatarGroup;
extern NSString *const TGNeoMessageAvatarUrl;
extern NSString *const TGNeoMessageAvatarColor;
extern NSString *const TGNeoMessageAvatarInitials;

extern NSString *const TGNeoMessageAudioButton;
extern NSString *const TGNeoMessageAudioIcon;