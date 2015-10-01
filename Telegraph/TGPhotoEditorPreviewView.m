#import "TGPhotoEditorPreviewView.h"

#import "TGFont.h"

#import "PGPhotoEditorView.h"

@interface TGPhotoEditorPreviewView ()
{
    UIView *_snapshotView;
    UIView *_transitionView;
    
    UIImageView *_originalBackgroundView;
    UILabel *_originalLabel;
    
    UILongPressGestureRecognizer *_pressGestureRecognizer;
    
    bool _needsTransitionIn;
}
@end

@implementation TGPhotoEditorPreviewView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[PGPhotoEditorView alloc] initWithFrame:self.bounds];
        _imageView.alpha = 0.0f;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_imageView];
        
        _pressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePress:)];
        _pressGestureRecognizer.minimumPressDuration = 0.1f;
        [_imageView addGestureRecognizer:_pressGestureRecognizer];
        
        static UIImage *background = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(21, 21), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, 0.7f).CGColor);

            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 21, 21) cornerRadius:6];

            [path fill];

            background = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            UIGraphicsEndImageContext();
        });
        
        _originalBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _originalBackgroundView.alpha = 0.0f;
        _originalBackgroundView.image = background;
        [self addSubview:_originalBackgroundView];
        
        _originalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _originalLabel.backgroundColor = [UIColor clearColor];
        _originalLabel.font = TGSystemFontOfSize(13);
        _originalLabel.textAlignment = NSTextAlignmentCenter;
        _originalLabel.textColor = [UIColor whiteColor];
        [_originalBackgroundView addSubview:_originalLabel];
    }
    return self;
}

- (void)setSnapshotImage:(UIImage *)image
{
    [_snapshotView removeFromSuperview];
    
    _snapshotView = [[UIImageView alloc] initWithImage:image];
    _snapshotView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _snapshotView.frame = self.bounds;
    [self insertSubview:_snapshotView atIndex:0];
}

- (void)setSnapshotView:(UIView *)view
{
    [_snapshotView removeFromSuperview];
    
    _snapshotView = view;
    _snapshotView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _snapshotView.frame = self.bounds;
    [self insertSubview:_snapshotView atIndex:0];
}

- (UIView *)originalSnapshotView
{
    return [_snapshotView snapshotViewAfterScreenUpdates:false];
}

- (void)prepareTransitionFadeView
{
    _transitionView = [_imageView snapshotViewAfterScreenUpdates:NO];
    _transitionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_transitionView];
}

- (void)performTransitionFade
{
    [UIView animateWithDuration:0.15f animations:^
    {
        _transitionView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        [_transitionView removeFromSuperview];
        _transitionView = nil;
    }];
}

- (void)performTransitionInWithCompletion:(void (^)(void))completion
{
    _needsTransitionIn = false;
    
    [UIView animateWithDuration:0.15f animations:^
    {
        _imageView.alpha = 1.0f;
    } completion:^(__unused BOOL finished)
    {
        if (completion != nil)
            completion();
    }];
}

- (void)setNeedsTransitionIn
{
    _needsTransitionIn = true;
}

- (void)performTransitionInIfNeeded
{
    if (_needsTransitionIn)
        [self performTransitionInWithCompletion:nil];
}

- (void)prepareForTransitionOut
{
    [_snapshotView removeFromSuperview];
}

- (void)performTransitionToCropAnimated:(bool)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.2f
                         animations:^
        {
            _imageView.alpha = 0.0f;
        }];
    }
    else
    {
        _imageView.alpha = 0.0f;
    }
}

- (void)handlePress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            _isTracking = true;
            
            if (self.touchedDown != nil)
            {
                self.touchedDown();
                
                [self setOriginalLabelText:TGLocalized(@"PhotoEditor.Current")];
            }
            else
            {
                [self setActualImageHidden:true animated:false];
                
                [self setOriginalLabelText:TGLocalized(@"PhotoEditor.Original")];
            }
            
            [self setOriginalLabelHidden:false animated:true];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            _isTracking = false;
            
            if (self.touchedUp != nil)
            {
                self.touchedUp();
            }
            else
            {
                [self setActualImageHidden:false animated:false];
            }
            
            if (self.interactionEnded != nil)
                self.interactionEnded();
            
            [self setOriginalLabelHidden:true animated:true];
        }
            break;
            
        default:
            break;
    }
}

- (void)setOriginalLabelText:(NSString *)text
{
    _originalLabel.text = text;
    [_originalLabel sizeToFit];
    _originalLabel.frame = CGRectMake(8, 6, CGCeil(_originalLabel.frame.size.width), CGCeil(_originalLabel.frame.size.height));
    
    CGFloat backWidth = _originalLabel.frame.size.width + 16;
    _originalBackgroundView.frame = CGRectMake((self.frame.size.width - backWidth) / 2, 15, backWidth, 28);
}

- (void)setOriginalLabelHidden:(bool)hidden animated:(bool)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            _originalBackgroundView.alpha = hidden ? 0.0f : 1.0f;
        } completion:nil];
    }
    else
    {
        _originalBackgroundView.alpha = hidden ? 0.0f : 1.0f;
    }
}

- (void)setActualImageHidden:(bool)hidden animated:(bool)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            _imageView.alpha = hidden ? 0.0f : 1.0f;
        } completion:nil];
    }
    else
    {
        _imageView.alpha = hidden ? 0.0f : 1.0f;
    }
}

@end
