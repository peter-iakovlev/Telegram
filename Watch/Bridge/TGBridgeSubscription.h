#import <Foundation/Foundation.h>

@interface TGBridgeSubscription : NSObject <NSCoding>

@property (nonatomic, readonly) int64_t identifier;
@property (nonatomic, readonly) NSString *name;

@property (nonatomic, readonly) bool isOneTime;
@property (nonatomic, readonly) bool renewable;
@property (nonatomic, readonly) bool dropPreviouslyQueued;
@property (nonatomic, readonly) bool synchronous;

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder;
- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder;

+ (NSString *)subscriptionName;

@end


@interface TGBridgeDisposal : NSObject <NSCoding>

@property (nonatomic, readonly) int64_t identifier;

- (instancetype)initWithIdentifier:(int64_t)identifier;

@end


@interface TGBridgePing : NSObject <NSCoding>

@property (nonatomic, readonly) int32_t sessionId;

- (instancetype)initWithSessionId:(int32_t)sessionId;

@end


@interface TGBridgeSubscriptionListRequest : NSObject <NSCoding>

@property (nonatomic, readonly) int32_t sessionId;

- (instancetype)initWithSessionId:(int32_t)sessionId;

@end


@interface TGBridgeSubscriptionList : NSObject <NSCoding>

@property (nonatomic, readonly) NSArray *subscriptions;

- (instancetype)initWithArray:(NSArray *)array;

@end
