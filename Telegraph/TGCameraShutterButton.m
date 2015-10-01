#import "TGCameraShutterButton.h"

#import "JNWSpringAnimation.h"

#import "TGCameraInterfaceAssets.h"
#import "TGModernButton.h"

@interface TGCameraShutterButton ()
{
    UIImageView *_ringView;
    TGModernButton *_buttonView;
}
@end

@implementation TGCameraShutterButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        static UIImage *ringImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(frame.size.width, frame.size.height), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();

            CGContextSetStrokeColorWithColor(context, [TGCameraInterfaceAssets normalColor].CGColor);
            CGContextSetLineWidth(context, 6.0);
            CGContextStrokeEllipseInRect(context, CGRectMake(3, 3, frame.size.width - 6, frame.size.height - 6));
                          
            ringImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        self.exclusiveTouch = true;
        
        _ringView = [[UIImageView alloc] initWithFrame:self.bounds];
        _ringView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _ringView.image = ringImage;
        [self addSubview:_ringView];
        
        _buttonView = [[TGModernButton alloc] initWithFrame:CGRectMake(8, 8, self.frame.size.width - 16, self.frame.size.height - 16)];
        _buttonView.backgroundColor = [TGCameraInterfaceAssets normalColor];
        _buttonView.layer.cornerRadius = _buttonView.frame.size.width / 2;
        [_buttonView addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_buttonView];
        
        [self setButtonMode:TGCameraShutterButtonNormalMode animated:false];
    }
    return self;
}

- (void)setButtonMode:(TGCameraShutterButtonMode)mode animated:(bool)animated
{
    if (animated)
    {
        switch (mode)
        {
            case TGCameraShutterButtonNormalMode:
            {
                [UIView animateWithDuration:0.25f animations:^
                {
                    _buttonView.backgroundColor = [TGCameraInterfaceAssets normalColor];
                }];
            }
                break;
                
            case TGCameraShutterButtonVideoMode:
            {
                [UIView animateWithDuration:0.25f animations:^
                {
                    _buttonView.backgroundColor = [TGCameraInterfaceAssets redColor];
                }];
            }
                break;
                
            case TGCameraShutterButtonRecordingMode:
            {
                [UIView animateWithDuration:0.25f animations:^
                {
                    _buttonView.backgroundColor = [TGCameraInterfaceAssets redColor];
                }];
                
                JNWSpringAnimation *cornersAnimation = [JNWSpringAnimation animationWithKeyPath:@"cornerRadius"];
                cornersAnimation.fromValue = @(_buttonView.layer.cornerRadius);
                cornersAnimation.toValue = @(4);
                cornersAnimation.mass = 5;
                cornersAnimation.damping = 100;
                cornersAnimation.stiffness = 300;
                [_buttonView.layer addAnimation:cornersAnimation forKey:@"cornerRadius"];
                _buttonView.layer.cornerRadius = 4;
                
                JNWSpringAnimation *boundsAnimation = [JNWSpringAnimation animationWithKeyPath:@"bounds"];
                boundsAnimation.fromValue = [NSValue valueWithCGRect:_buttonView.layer.bounds];
                boundsAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, self.frame.size.width - 38, self.frame.size.height - 38)];
                boundsAnimation.mass = 5;
                boundsAnimation.damping = 100;
                boundsAnimation.stiffness = 300;
                [_buttonView.layer addAnimation:boundsAnimation forKey:@"bounds"];
                _buttonView.layer.bounds = CGRectMake(0, 0, self.frame.size.width - 38, self.frame.size.height - 38);
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        switch (mode)
        {
            case TGCameraShutterButtonNormalMode:
            {
                _buttonView.backgroundColor = [TGCameraInterfaceAssets normalColor];
                _buttonView.frame = CGRectMake(8, 8, self.frame.size.width - 16, self.frame.size.height - 16);
                _buttonView.layer.cornerRadius = _buttonView.frame.size.width / 2;
            }
                break;
                
            case TGCameraShutterButtonVideoMode:
            {
                _buttonView.backgroundColor = [TGCameraInterfaceAssets redColor];
                _buttonView.frame = CGRectMake(8, 8, self.frame.size.width - 16, self.frame.size.height - 16);
                _buttonView.layer.cornerRadius = _buttonView.frame.size.width / 2;
            }
                break;
                
            case TGCameraShutterButtonRecordingMode:
            {
                _buttonView.backgroundColor = [TGCameraInterfaceAssets redColor];
                _buttonView.frame = CGRectMake(19, 19, self.frame.size.width - 38, self.frame.size.height - 38);                
                _buttonView.layer.cornerRadius = 4;
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)buttonPressed
{
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];

    [_buttonView setHighlighted:highlighted];
}

@end
