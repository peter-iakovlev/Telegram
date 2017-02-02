#import <Foundation/Foundation.h>
#import "TGOverlayController.h"

@class TGConversation;
@class TGChatActionsHandle;

@interface TGChatActionsController : TGOverlayController

- (instancetype)initWithParentController:(TGViewController *)parentController conversation:(TGConversation *)conversation parametersBlock:(NSDictionary *(^)(TGConversation *))parametersBlock;

- (void)handleTouchForce:(CGFloat)force;

- (void)presentAnimated:(bool)animated;
- (void)dismissAnimated:(bool)animated;

+ (TGChatActionsHandle *)setupActionsControllerForParentController:(TGViewController *)parentController view:(UIView *)view conversationForLocation:(TGConversation *(^)(CGPoint gestureLocation))conversationBlock parametersForConversation:(NSDictionary *(^)(TGConversation *conversation))parametersBlock;

@end


@interface TGChatActionsHandle : NSObject

@end

extern NSString *const TGChatActionsSourceRectKey;
extern NSString *const TGChatActionsAvatarSnapshotKey;
