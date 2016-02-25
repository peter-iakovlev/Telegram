#import <UIKit/UIKit.h>

@interface TGShareSheetItemView : UIView

@property (nonatomic, copy) void (^preferredHeightNeedsUpdate)(TGShareSheetItemView *);

- (CGFloat)preferredHeightForMaximumHeight:(CGFloat)maximumHeight;
- (bool)followsKeyboard;
- (void)setPreferredHeightNeedsUpdate;

- (void)sheetDidAppear;
- (void)sheetWillDisappear;

- (void)setHighlightedImage:(UIImage *)highlightedImage;

@end
