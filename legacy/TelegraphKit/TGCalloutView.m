#import "TGCalloutView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

@interface TGCalloutView ()

@property (nonatomic, strong) UIImageView *arrowView;

@property (nonatomic, strong) UIImageView *leftView;
@property (nonatomic, strong) UIImageView *centerView;
@property (nonatomic, strong) UIImageView *rightView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@end

@implementation TGCalloutView

@synthesize arrowView = _arrowView;

@synthesize leftView = _leftView;
@synthesize centerView = _centerView;
@synthesize rightView = _rightView;

@synthesize titleLabel = _titleLabel;
@synthesize subtitleLabel = _subtitleLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    UIImage *rawLeftImage = [UIImage imageNamed:@"MapCalloutLeft.png"];
    UIImage *rawLeftHighlightedImage = [UIImage imageNamed:@"MapCalloutLeft_Highlighted.png"];
    UIImage *rawRightImage = [UIImage imageNamed:@"MapCalloutRight.png"];
    UIImage *rawRightHighlightedImage = [UIImage imageNamed:@"MapCalloutRight_Highlighted.png"];
    
    UIImage *centerImage = [UIImage imageNamed:@"MapCalloutCenter.png"];
    UIImage *centerHighlightedImage = [UIImage imageNamed:@"MapCalloutCenter_Highlighted.png"];
    
    _leftView = [[UIImageView alloc] initWithImage:[rawLeftImage stretchableImageWithLeftCapWidth:(int)(rawLeftImage.size.width - 1) topCapHeight:0] highlightedImage:[rawLeftHighlightedImage stretchableImageWithLeftCapWidth:(int)(rawLeftHighlightedImage.size.width - 1) topCapHeight:0]];
    [self addSubview:_leftView];
    
    _rightView = [[UIImageView alloc] initWithImage:[rawRightImage stretchableImageWithLeftCapWidth:1 topCapHeight:0] highlightedImage:[rawRightHighlightedImage stretchableImageWithLeftCapWidth:1 topCapHeight:0]];
    [self addSubview:_rightView];
    
    _centerView = [[UIImageView alloc] initWithImage:centerImage highlightedImage:centerHighlightedImage];
    [self addSubview:_centerView];
    
    _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MapCalloutArrow.png"]];
    [self addSubview:_arrowView];
    
    _subtitleLabel = [[UILabel alloc] init];
    _subtitleLabel.font = TGSystemFontOfSize(12);
    _subtitleLabel.textColor = TGAccentColor();
    _subtitleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_subtitleLabel];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = TGSystemFontOfSize(15);
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_titleLabel];
}

- (void)sizeToFit
{
    CGRect frame = self.frame;
    
    [_titleLabel sizeToFit];
    [_subtitleLabel sizeToFit];
    
    CGFloat labelsWidth = MAX(_titleLabel.frame.size.width, _subtitleLabel.frame.size.width) + 30 + 13;
    
    frame.size.width = MIN(300, MAX(MAX(_leftView.image.size.width + _rightView.image.size.width + _centerView.image.size.width, labelsWidth), 194));
    frame.size.height = _leftView.image.size.height;
    
    self.frame = frame;
}

- (void)setTitleText:(NSString *)titleText
{
    [_titleLabel setText:titleText];
}

- (void)setSubtitleText:(NSString *)subtitleText
{
    [_subtitleLabel setText:subtitleText];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    _leftView.highlighted = highlighted;
    _rightView.highlighted = highlighted;
    _centerView.highlighted = highlighted;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize viewSize = self.frame.size;
    
    _centerView.frame = CGRectMake(CGFloor((viewSize.width - _centerView.image.size.width) / 2), 0, _centerView.image.size.width, viewSize.height);
    _leftView.frame = CGRectMake(0, 0, _centerView.frame.origin.x, viewSize.height);
    _rightView.frame = CGRectMake(_centerView.frame.origin.x + _centerView.frame.size.width, 0, viewSize.width - (_centerView.frame.origin.x + _centerView.frame.size.width), viewSize.height);
    
    _arrowView.frame = CGRectMake(viewSize.width - _arrowView.frame.size.width - 11, 18, _arrowView.frame.size.width, _arrowView.frame.size.height);
    
    if (_subtitleLabel.text.length == 0)
    {
        _titleLabel.frame = CGRectMake(13, 15, viewSize.width - 30 - 12, _titleLabel.frame.size.height);
        _subtitleLabel.frame = CGRectMake(13, 14, viewSize.width - 30 - 12, _subtitleLabel.frame.size.height);
        _subtitleLabel.alpha = 0.0f;
    }
    else
    {
        _titleLabel.frame = CGRectMake(13, 7, viewSize.width - 30 - 12, _titleLabel.frame.size.height);
        _subtitleLabel.frame = CGRectMake(13, 27, viewSize.width - 30 - 12, _subtitleLabel.frame.size.height);
        _subtitleLabel.alpha = 1.0f;
    }
}

- (void)cancelDoubleTap:(UIView *)view
{
    for (UIGestureRecognizer *recognizer in view.gestureRecognizers)
    {
        if ([recognizer isKindOfClass:[UITapGestureRecognizer class]] && ((UITapGestureRecognizer *)recognizer).numberOfTapsRequired == 2)
        {
            if (recognizer.enabled)
            {
                recognizer.enabled = false;
                recognizer.enabled = true;
            }
        }
    }
    
    if (view.superview != nil)
        [self cancelDoubleTap:view.superview];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (iosMajorVersion() >= 6)
        [self cancelDoubleTap:self.superview];
    
    [super touchesBegan:touches withEvent:event];
}

@end
