#import <UIKit/UIKit.h>

@interface TGModernGalleryPIPHeaderView : UIView

@property (nonatomic, copy) void (^pipPressed)();

- (void)setPictureInPictureHidden:(bool)hidden;
- (void)setPictureInPictureEnabled:(bool)enabled;

@end
