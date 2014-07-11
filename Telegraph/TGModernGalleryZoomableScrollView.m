#import "TGModernGalleryZoomableScrollView.h"

#import "TGDoubleTapGestureRecognizer.h"

@interface TGModernGalleryZoomableScrollView () <TGDoubleTapGestureRecognizerDelegate>

@end

@implementation TGModernGalleryZoomableScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        TGDoubleTapGestureRecognizer *recognizer = [[TGDoubleTapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture:)];
        recognizer.consumeSingleTap = true;

        [self addGestureRecognizer:recognizer];
    }
    return self;
}

- (void)doubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        if (_doubleTapped)
            _doubleTapped();
    }
}

- (void)doubleTapGestureRecognizerSingleTapped:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
    if (_singleTapped)
        _singleTapped();
}

@end
