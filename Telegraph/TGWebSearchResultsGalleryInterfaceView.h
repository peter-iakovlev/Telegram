#import <UIKit/UIKit.h>

#import "TGModernGalleryItem.h"

#import "TGModernGalleryInterfaceView.h"

@interface TGWebSearchResultsGalleryInterfaceView : UIView <TGModernGalleryInterfaceView>

@property (nonatomic, copy) void (^itemSelected)(id<TGModernGalleryItem>);
@property (nonatomic, copy) bool (^isItemSelected)(id<TGModernGalleryItem>);
@property (nonatomic, copy) void (^donePressed)(id<TGModernGalleryItem>);

@property (nonatomic) bool showStatusBar;

- (void)updateSelectionInterface:(NSUInteger)selectedCount animated:(bool)animated;

@end
