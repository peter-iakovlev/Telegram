#import <Foundation/Foundation.h>
#import "TGOverlayController.h"

@interface TGPickerSheetOverlayController : TGOverlayController

- (instancetype)init;
- (instancetype)initWithDateMode:(bool)banTimeout;

@end


@interface TGPickerSheet : NSObject

@property (nonatomic, strong) NSString *emptyValue;

- (instancetype)initWithDateSelection:(void (^)(NSTimeInterval item))action banTimeout:(bool)banTimeout;
- (instancetype)initWithItems:(NSArray *)items selectedIndex:(NSUInteger)selectedIndex action:(void (^)(id item))action;

- (void)show;
- (void)showFromRect:(CGRect)rect inView:(UIView *)view;
- (void)dismiss;

@end
