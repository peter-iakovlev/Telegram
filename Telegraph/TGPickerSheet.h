#import <Foundation/Foundation.h>
#import "TGOverlayController.h"

@interface TGPickerSheetOverlayController : TGOverlayController

@end


@interface TGPickerSheet : NSObject

@property (nonatomic, strong) NSString *emptyValue;

- (instancetype)initWithItems:(NSArray *)items selectedIndex:(NSUInteger)selectedIndex action:(void (^)(id item))action;

- (void)show;
- (void)showFromRect:(CGRect)rect inView:(UIView *)view;
- (void)dismiss;

@end
