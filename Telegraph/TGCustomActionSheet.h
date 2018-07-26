#import <Foundation/Foundation.h>
#import "TGActionSheet.h"

@class TGViewController;
@class TGMenuSheetController;

@interface TGCustomActionSheet : NSObject

@property (nonatomic, readonly) TGMenuSheetController *controller;

- (instancetype)initWithTitle:(NSString *)title actions:(NSArray *)actions actionBlock:(void (^)(id target, NSString *action))actionBlock target:(id)target;
- (instancetype)initWithTitle:(NSString *)title actions:(NSArray *)actions menuController:(TGMenuSheetController *)menuController advancedActionBlock:(void (^)(TGMenuSheetController *controller, id target, NSString *action))actionBlock target:(id)target;

- (void)showInView:(UIView *)view;
- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(bool)animated;

@end
