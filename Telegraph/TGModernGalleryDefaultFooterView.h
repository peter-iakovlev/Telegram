#import <UIKit/UIKit.h>

#import "TGModernGalleryItem.h"

@protocol TGModernGalleryDefaultFooterView <NSObject>

@required

- (void)setItem:(id<TGModernGalleryItem>)item;

@end
