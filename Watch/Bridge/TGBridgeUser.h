#import "TGBridgeCommon.h"

@class TGBridgeBotInfo;
@class TGBridgeUserChange;

typedef enum
{
    TGBridgeUserKindGeneric,
    TGBridgeUserKindBot,
    TGBridgeUserKindSmartBot
} TGBridgeUserKind;

typedef enum
{
    TGBridgeBotKindGeneric,
    TGBridgeBotKindPrivate
} TGBridgeBotKind;

@interface TGBridgeUser : NSObject <NSCoding, NSCopying>
{
    int32_t _identifier;
    NSString *_firstName;
    NSString *_lastName;
    NSString *_userName;
    NSString *_phoneNumber;
    NSString *_prettyPhoneNumber;
    bool _online;
    NSTimeInterval _lastSeen;
    NSString *_photoSmall;
    NSString *_photoBig;
    
    TGBridgeUserKind _kind;
    TGBridgeBotKind _botKind;
    int32_t _botVersion;
    
    int32_t _userVersion;
}

@property (nonatomic, readonly) int32_t identifier;
@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSString *userName;
@property (nonatomic, readonly) NSString *phoneNumber;
@property (nonatomic, readonly) NSString *prettyPhoneNumber;

@property (nonatomic, readonly, getter=isOnline) bool online;
@property (nonatomic, readonly) NSTimeInterval lastSeen;

@property (nonatomic, readonly) NSString *photoSmall;
@property (nonatomic, readonly) NSString *photoBig;

@property (nonatomic, readonly) TGBridgeUserKind kind;
@property (nonatomic, readonly) TGBridgeBotKind botKind;
@property (nonatomic, readonly) int32_t botVersion;

@property (nonatomic, readonly) int32_t userVersion;

- (NSString *)displayName;
- (TGBridgeUserChange *)changeFromUser:(TGBridgeUser *)user;
- (TGBridgeUser *)userByApplyingChange:(TGBridgeUserChange *)change;

- (bool)isBot;

@end


@interface TGBridgeUserChange : NSObject <NSCoding>

@property (nonatomic, readonly) int32_t userIdentifier;
@property (nonatomic, readonly) NSDictionary *fields;

- (instancetype)initWithUserIdentifier:(int32_t)userIdentifier fields:(NSDictionary *)fields;

@end

extern NSString *const TGBridgeUsersDictionaryKey;
