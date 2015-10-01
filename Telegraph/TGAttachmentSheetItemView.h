#import <UIKit/UIKit.h>

@interface TGAttachmentSheetItemView : UIView

@property (nonatomic) bool showsTopSeparator;
@property (nonatomic) bool showsBottomSeparator;

- (CGFloat)preferredHeight;

- (bool)wantsFullSeparator;

- (void)sheetDidAppear;
- (void)sheetWillDisappear;

@end
