#import <UIKit/UIKit.h>

@interface TGSharedMediaSelectionPanelView : UIView

@property (nonatomic) NSUInteger selecterItemCount;
@property (nonatomic, copy) void (^deleteSelectedItems)();
@property (nonatomic, copy) void (^forwardSelectedItems)();
@property (nonatomic, copy) void (^shareSelectedItems)();
@property (nonatomic) bool forwardEnabled;
@property (nonatomic) bool deleteEnabled;
@property (nonatomic) bool shareEnabled;

@end
