#import <Foundation/Foundation.h>

@class TGViewController;

@interface TGMediaAvatarMenuMixin : NSObject

@property (nonatomic, copy) void (^didFinishWithImage)(UIImage *image);
@property (nonatomic, copy) void (^didFinishWithDelete)(void);
@property (nonatomic, copy) void (^didDismiss)(void);

- (instancetype)initWithParentController:(TGViewController *)parentController hasDeleteButton:(bool)hasDeleteButton;
- (instancetype)initWithParentController:(TGViewController *)parentController hasDeleteButton:(bool)hasDeleteButton personalPhoto:(bool)personalPhoto;
- (void)present;

@end
