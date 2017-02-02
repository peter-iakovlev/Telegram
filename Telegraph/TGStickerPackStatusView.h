#import <UIKit/UIKit.h>

#import "TGStickerPackCollectionItem.h"

@interface TGStickerPackStatusView : UIView

@property (nonatomic, copy) void (^install)();

- (void)setStatus:(TGStickerPackItemStatus)status;

@end
