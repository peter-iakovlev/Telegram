#import <UIKit/UIKit.h>

#import "TGModernGalleryItem.h"

@protocol TGModernGalleryDefaultHeaderView <NSObject>

@required

- (void)setItem:(id<TGModernGalleryItem>)item;

@end