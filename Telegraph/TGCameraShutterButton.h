#import <UIKit/UIKit.h>

typedef enum
{
    TGCameraShutterButtonNormalMode,
    TGCameraShutterButtonVideoMode,
    TGCameraShutterButtonRecordingMode
} TGCameraShutterButtonMode;

@interface TGCameraShutterButton : UIControl

- (void)setButtonMode:(TGCameraShutterButtonMode)mode animated:(bool)animated;

@end
