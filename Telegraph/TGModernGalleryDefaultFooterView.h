#import <UIKit/UIKit.h>

#import "TGModernGalleryItem.h"

@protocol TGModernGalleryDefaultFooterView <NSObject>

@optional
- (void)setTransitionOutProgress:(CGFloat)transitionOutProgress;
- (void)setContentHidden:(bool)contentHidden;

@required

- (void)setItem:(id<TGModernGalleryItem>)item;

@end
