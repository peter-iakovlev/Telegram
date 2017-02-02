#import <Foundation/Foundation.h>

@class TGViewController;
@class TGItemPreviewController;
@class TGBotContextResult;
@class TGBotContextResults;

@class TGItemPreviewHandle;

@interface TGPreviewMenu : NSObject

+ (TGItemPreviewController *)presentInParentController:(TGViewController *)parentController expandImmediately:(bool)expandImmediately result:(TGBotContextResult *)result results:(TGBotContextResults *)results sendAction:(void (^)(TGBotContextResult *))sendAction sourcePointForItem:(CGPoint (^)(id item))sourcePointForItem sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect;

+ (TGItemPreviewHandle *)setupPreviewControllerForView:(UIView *)view configurator:(TGItemPreviewController *(^)(CGPoint gestureLocation))configurator;

+ (bool)hasNoPreviewForResult:(TGBotContextResult *)result;

@end

@interface TGItemPreviewHandle : NSObject

@property (nonatomic, assign) NSTimeInterval requiredPressDuration;

@end
