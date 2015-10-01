#import <UIKit/UIKit.h>

@interface TGSharedMediaSelectionPanelView : UIView

@property (nonatomic) NSUInteger selecterItemCount;
@property (nonatomic, copy) void (^deleteSelectedItems)();
@property (nonatomic, copy) void (^shareSelectedItems)();
@property (nonatomic) bool shareEnabled;
@property (nonatomic) bool deleteEnabled;

@end
