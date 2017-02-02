#import "TGInstantPageLinkSelectionView.h"

static UIImage *selectionImageWithRects(NSArray<NSValue *> *rects, CGSize size, CGFloat inset) {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width + inset + inset, size.height + inset + inset), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, inset, inset);
    
    CGContextSetFillColorWithColor(context, [TGAccentColor() colorWithAlphaComponent:0.3f].CGColor);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGFloat radius = 2.0f;
    
    for (NSValue *lineFrameValue in rects.reverseObjectEnumerator) {
        CGRect lineFrame = [lineFrameValue CGRectValue];
        lineFrame = CGRectInset(lineFrame, -inset, -inset);
        
        CGContextMoveToPoint(context, CGRectGetMinX(lineFrame) + radius, CGRectGetMinY(lineFrame));
        CGContextAddLineToPoint(context, CGRectGetMaxX(lineFrame) - radius, CGRectGetMinY(lineFrame));
        CGContextAddArcToPoint(context, CGRectGetMaxX(lineFrame), CGRectGetMinY(lineFrame), CGRectGetMaxX(lineFrame), CGRectGetMinY(lineFrame) + radius, radius);
        CGContextAddLineToPoint(context, CGRectGetMaxX(lineFrame), CGRectGetMaxY(lineFrame) - radius);
        CGContextAddArcToPoint(context, CGRectGetMaxX(lineFrame), CGRectGetMaxY(lineFrame), CGRectGetMaxX(lineFrame) - radius, CGRectGetMaxY(lineFrame), radius);
        CGContextAddLineToPoint(context, CGRectGetMinX(lineFrame) + radius, CGRectGetMaxY(lineFrame));
        CGContextAddArcToPoint(context, CGRectGetMinX(lineFrame), CGRectGetMaxY(lineFrame), CGRectGetMinX(lineFrame), CGRectGetMaxY(lineFrame) - radius, radius);
        CGContextAddLineToPoint(context, CGRectGetMinX(lineFrame), CGRectGetMinY(lineFrame) + radius);
        CGContextAddArcToPoint(context, CGRectGetMinX(lineFrame), CGRectGetMinY(lineFrame), CGRectGetMinX(lineFrame) + radius, CGRectGetMinY(lineFrame), radius);
        CGContextFillPath(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

static CGFloat inset = 4.0f;

@interface TGInstantPageLinkSelectionView () {
    NSArray<NSValue *> *_rects;
    id _urlItem;
    UIImageView *_imageView;
}

@end

@implementation TGInstantPageLinkSelectionView

- (instancetype)initWithFrame:(CGRect)frame rects:(NSArray<NSValue *> *)rects urlItem:(id)urlItem {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _rects = rects;
        _urlItem = urlItem;
        self.opaque = false;
        self.backgroundColor = nil;
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-inset, -inset, frame.size.width + inset + inset, frame.size.height + inset + inset)];
        [self addSubview:_imageView];
        
        [self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        if (_imageView.image == nil) {
            _imageView.image = selectionImageWithRects(_rects, self.bounds.size, inset);
        }
    } else if (_imageView.image != nil) {
        _imageView.image = nil;
    }
}

- (void)buttonPressed {
    if (_itemTapped) {
        _itemTapped(_urlItem);
    }
}

@end
