#import "TGTransitionableImageView.h"

@interface TGTransitionableImageView ()

@property (nonatomic, strong) UIImageView *primaryImageView;
@property (nonatomic, strong) UIImageView *secondaryImageView;

@end

@implementation TGTransitionableImageView

@synthesize primaryImageView = _primaryImageView;
@synthesize secondaryImageView = _secondaryImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self commonInit:nil];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self != nil)
    {
        [self commonInit:image];
    }
    return self;
}

- (void)commonInit:(UIImage *)image
{
    _secondaryImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _secondaryImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _secondaryImageView.hidden = true;
    [self addSubview:_secondaryImageView];
    
    _primaryImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _primaryImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _primaryImageView.hidden = false;
    if (image != nil)
        _primaryImageView.image = image;
    [self addSubview:_primaryImageView];
}

- (void)setImage:(UIImage *)image
{
    _secondaryImageView.image = nil;
    _secondaryImageView.hidden = true;
    _secondaryImageView.alpha = 0.0f;
    
    _primaryImageView.image = image;
    _primaryImageView.alpha = 1.0f;
}

- (void)transitionToImage:(UIImage *)image duration:(NSTimeInterval)duration
{
    duration = 0.2;
    
    _secondaryImageView.image = _primaryImageView.image;
    _primaryImageView.image = image;
    
    _secondaryImageView.hidden = false;
    _secondaryImageView.alpha = 1.0f;
    _primaryImageView.alpha = 0.0f;
    
    [UIView animateWithDuration:duration delay:0.1 options:0 animations:^
    {
        _secondaryImageView.alpha = 0.0f;   
    } completion:^(BOOL finished)
    {
        if (finished)
        {
            _secondaryImageView.hidden = true;
            _secondaryImageView.image = nil;
        }
    }];
    
    [UIView animateWithDuration:duration animations:^
    {
        _primaryImageView.alpha = 1.0f;
    } completion:nil];
}

@end
