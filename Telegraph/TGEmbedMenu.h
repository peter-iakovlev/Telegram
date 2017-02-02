#import <Foundation/Foundation.h>

@class TGViewController;
@class TGMenuSheetController;
@class TGWebPageMediaAttachment;

@interface TGEmbedMenu : NSObject

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController attachment:(TGWebPageMediaAttachment *)attachment peerId:(int64_t)peerId messageId:(int32_t)messageId cancelPIP:(bool)cancelPIP sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect;

+ (bool)isEmbedMenuController:(TGMenuSheetController *)menuController;

@end
