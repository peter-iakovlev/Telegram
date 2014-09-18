//
//  RMIntroViewController.h
//  IntroOpenGL
//
//  Created by Ilya Rimchikov on 19/01/14.
//
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
//#import "RMRootViewController.h"

typedef enum {
    Inch35 = 0,
    Inch4 = 1,
    Inch47 = 2,
    Inch55 = 3
} DeviceScreen;

@interface RMIntroViewController : UIViewController<UIScrollViewDelegate, GLKViewDelegate>
{
    DeviceScreen _deviceScreen;
    
    EAGLContext *context;
    
    GLKView *_glkView;
    
    
    UIImageView *_startArrow;
    
    NSArray *_headlines;
    NSArray *_descriptions;
    
    NSMutableArray *_pageViews;
    
    UIView *_separatorView;
    
    //RMTestView *_iconView;
    
    UIScrollView *_pageScrollView;
    
    NSInteger _currentPage;
    
    UIButton *_startButton;
    UIPageControl *_pageControl;
    
    
    
    
    NSTimer *_updateAndRenderTimer;
    
    
    BOOL _isOpenGLLoaded;
}

@property (nonatomic) UIViewController *rootVC;
@property (nonatomic, assign) NSInteger draw_q;



- (void)startTimer;

- (void)stopTimer;


@end
