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

@interface RMIntroViewController : UIViewController<UIScrollViewDelegate, GLKViewDelegate>
{
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
