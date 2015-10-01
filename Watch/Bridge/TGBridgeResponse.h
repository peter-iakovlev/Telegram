#import <Foundation/Foundation.h>

@class TGBridgeSubscription;

typedef NS_ENUM(int32_t, TGBridgeResponseType) {
    TGBridgeResponseTypeUndefined,
    TGBridgeResponseTypeNext,
    TGBridgeResponseTypeFailed,
    TGBridgeResponseTypeCompleted
};

@interface TGBridgeResponse : NSObject <NSCoding>

@property (nonatomic, readonly) int64_t subscriptionIdentifier;

@property (nonatomic, readonly) TGBridgeResponseType type;
@property (nonatomic, readonly) id next;
@property (nonatomic, readonly) NSString *error;

+ (TGBridgeResponse *)single:(id)next forSubscription:(TGBridgeSubscription *)subscription;
+ (TGBridgeResponse *)fail:(id)error forSubscription:(TGBridgeSubscription *)subscription;
+ (TGBridgeResponse *)completeForSubscription:(TGBridgeSubscription *)subscription;

@end
