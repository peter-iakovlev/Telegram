#import "TGImageScrollView.h"

#import "TGDoubleTapGestureRecognizer.h"

@interface TGImageScrollView ()

@end

@implementation TGImageScrollView

@synthesize adjustedZoomScale = _adjustedZoomScale;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self commonInit];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        [self commonInit];
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
}

- (void)commonInit
{
    TGDoubleTapGestureRecognizer *doubleTapRecognizer = [[TGDoubleTapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognized:)];
    [self addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    [self addGestureRecognizer:tapRecognizer];
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        __strong id delegate = self.delegate;
        if (delegate != nil && [delegate conformsToProtocol:@protocol(TGImageScrollViewDelegate)])
            [(id<TGImageScrollViewDelegate>)delegate scrollViewTapped];
    }
}

- (void)doubleTapGestureRecognized:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized && recognizer.doubleTapped)
    {
        __strong id delegate = self.delegate;
        if (delegate != nil && [delegate conformsToProtocol:@protocol(TGImageScrollViewDelegate)])
            [(id<TGImageScrollViewDelegate>)delegate scrollViewDoubleTapped:[recognizer locationInView:self]];
    }
}

- (void)updateZoomScale
{
    self.scrollEnabled = self.zoomScale > _adjustedZoomScale + FLT_EPSILON;
}

- (bool)isAdjustedToFill
{
    float zoomScale = self.zoomScale;
    //float minimumZoomScale = self.minimumZoomScale;
    float maximumZoomScale = self.maximumZoomScale;
    
    return ABS(zoomScale - maximumZoomScale) < FLT_EPSILON;
    
    //float adjustedZoomScale = _adjustedZoomScale;
    
    //return ABS(zoomScale - adjustedZoomScale) < FLT_EPSILON && adjustedZoomScale > minimumZoomScale - FLT_EPSILON;
}

- (void)setZoomScale:(float)zoomScale
{
    [super setZoomScale:zoomScale];
    
    [self updateZoomScale];
}

- (void)setZoomScale:(float)scale animated:(BOOL)animated
{
    [super setZoomScale:scale animated:animated];
    
    [self updateZoomScale];
}

@end
