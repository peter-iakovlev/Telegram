#import "TGProgressWindow.h"

#import "TGActivityIndicatorView.h"

#import "TGAppDelegate.h"

#import "TGNotificationWindow.h"

@interface TGProgressWindow ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation TGProgressWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.windowLevel = UIWindowLevelStatusBar;
        
        self.rootViewController = [[TGOverlayWindowViewController alloc] init];
        
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(floorf(self.frame.size.width - 100) / 2, floorf(self.frame.size.height - 100) / 2, 100, 100)];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _containerView.alpha = 0.0f;
        [self addSubview:_containerView];
        
        UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:_containerView.bounds];
        UIImage *rawImage = [UIImage imageNamed:@"ProgressWindowBackground.png"];
        backgroundView.image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:(int)(rawImage.size.height / 2)];
        [_containerView addSubview:backgroundView];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.frame = CGRectOffset(_activityIndicatorView.frame, (int)((_containerView.frame.size.width - _activityIndicatorView.frame.size.width) / 2), (int)((_containerView.frame.size.height - _activityIndicatorView.frame.size.height) / 2));
        [_containerView addSubview:_activityIndicatorView];
        [_activityIndicatorView startAnimating];
        
        self.opaque = false;
    }
    return self;
}

- (void)show:(bool)animated
{
    CGFloat rotation = 0.0f;
    switch ([[UIApplication sharedApplication] statusBarOrientation])
    {
        case UIInterfaceOrientationPortrait:
            rotation = 0.0f;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotation = (CGFloat)-M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotation = (CGFloat)M_PI_2;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            rotation = (CGFloat)M_PI;
            break;
        default:
            break;
    }
    _containerView.transform = CGAffineTransformMakeRotation(rotation);
    
    self.userInteractionEnabled = true;
    [self makeKeyAndVisible];
    
    if (animated)
    {
        [UIView animateWithDuration:0.3f animations:^
        {
            _containerView.alpha = 1.0f;
        }];
    }
    else
        _containerView.alpha = 1.0f;
}

- (void)dismiss:(bool)animated
{
    self.userInteractionEnabled = false;
    if (animated)
    {
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            _containerView.alpha = 0.0f;
        } completion:^(BOOL finished)
        {
            if (finished)
            {
                self.hidden = true;
                
                NSArray *windows = [[UIApplication sharedApplication] windows];
                for (int i = windows.count - 1; i >= 0; i--)
                {
                    if ([windows objectAtIndex:i] != self)
                        [[windows objectAtIndex:i] makeKeyWindow];
                }
            }
        }];
    }
    else
    {
        _containerView.alpha = 0.0f;
        self.hidden = true;
        
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (int i = windows.count - 1; i >= 0; i--)
        {
            if ([windows objectAtIndex:i] != self)
                [[windows objectAtIndex:i] makeKeyWindow];
        }
    }
}

- (void)dismissWithSuccess
{
    [_activityIndicatorView removeFromSuperview];
    self.userInteractionEnabled = false;
    
    UIImageView *checkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ProgressWindowCheck.png"]];
    checkView.frame = CGRectOffset(checkView.frame, floorf((_containerView.frame.size.width - checkView.frame.size.width) / 2), floorf((_containerView.frame.size.height - checkView.frame.size.height) / 2));
    [_containerView addSubview:checkView];
    
    [UIView animateWithDuration:0.3 delay:0.5 options:0 animations:^
    {
        _containerView.alpha = 0.0f;
    } completion:^(BOOL finished)
    {
        if (finished)
        {
            self.hidden = true;
            
            NSArray *windows = [[UIApplication sharedApplication] windows];
            for (int i = windows.count - 1; i >= 0; i--)
            {
                if ([windows objectAtIndex:i] != self)
                    [[windows objectAtIndex:i] makeKeyWindow];
            }
        }
    }];
}

@end
