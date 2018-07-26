#import <UIKit/UIKit.h>

#import "TGStickerPackCollectionItem.h"

@class TGPresentation;

@interface TGStickerPackStatusView : UIView

@property (nonatomic, copy) void (^install)();
@property (nonatomic, strong) TGPresentation *presentation;

- (void)setStatus:(TGStickerPackItemStatus)status;

@end
