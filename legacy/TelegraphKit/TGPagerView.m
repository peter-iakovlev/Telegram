#import "TGPagerView.h"

@interface TGPagerView ()
{
    CGFloat _dotSize;
    NSArray *_dotColors;
    CGFloat _shadowWidth;
    NSMutableArray *_dotNormalViews;
    NSMutableArray *_dotHighlightedViews;
    
    UIImage *_normalDotImage;
}

@end

@implementation TGPagerView

- (instancetype)initWithDotColors:(NSArray *)colors
{
    return [self initWithDotColors:colors dotSize:7.0f];
}

- (instancetype)initWithDotColors:(NSArray *)colors dotSize:(CGFloat)dotSize
{
    return [self initWithDotColors:colors normalDotColor:UIColorRGB(0xe5e5e5) dotSpacing:9.0f dotSize:dotSize];
}

- (instancetype)initWithDotColors:(NSArray *)colors normalDotColor:(UIColor *)normalDotColor dotSpacing:(CGFloat)dotSpacing dotSize:(CGFloat)dotSize
{
    return [self initWithDotColors:colors normalDotColor:normalDotColor dotSpacing:dotSpacing dotSize:dotSize shadowWidth:0.0f];
}


- (instancetype)initWithDotColors:(NSArray *)colors normalDotColor:(UIColor *)normalDotColor dotSpacing:(CGFloat)dotSpacing dotSize:(CGFloat)dotSize shadowWidth:(CGFloat)shadowWidth
{
    self = [super init];
    if (self != nil)
    {
        _dotColors = colors;
        _dotSize = dotSize;
        _dotNormalViews = [[NSMutableArray alloc] init];
        _dotHighlightedViews = [[NSMutableArray alloc] init];
        _dotSpacing = dotSpacing;
        _shadowWidth = shadowWidth;
        
        _normalDotImage = [self dotImageWithColor:normalDotColor shadowWidth:_shadowWidth];
    }
    return self;
}

- (UIImage *)dotImageWithColor:(UIColor *)color shadowWidth:(CGFloat)shadowWidth
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(_dotSize, _dotSize), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    if (shadowWidth > FLT_EPSILON)
    {
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.0f alpha:0.25f].CGColor);
        CGContextSetLineWidth(context, shadowWidth);
        CGContextStrokeEllipseInRect(context, CGRectMake(shadowWidth / 2.0f, shadowWidth / 2.0f, _dotSize - shadowWidth, _dotSize - shadowWidth));
    }
    
    CGContextFillEllipseInRect(context, CGRectMake(shadowWidth / 2.0f, shadowWidth / 2.0f, _dotSize - shadowWidth, _dotSize - shadowWidth));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)setPagesCount:(int)count
{
    if (_dotNormalViews.count != (NSUInteger)count)
    {
        bool resetPage = false;
        
        if (count < (int)_dotNormalViews.count)
        {
            for (int i = (int)_dotNormalViews.count - 1; i >= count; i--)
            {
                UIView *view = [_dotNormalViews objectAtIndex:i];
                [view removeFromSuperview];
                
                view = [_dotHighlightedViews objectAtIndex:i];
                [view removeFromSuperview];
                
                [_dotNormalViews removeObjectAtIndex:i];
                [_dotHighlightedViews removeObjectAtIndex:i];
            }
        }
        else if (count > (int)_dotNormalViews.count)
        {
            if (_dotNormalViews.count == 0)
                resetPage = true;
            int index = (int)_dotNormalViews.count - 1;
            while ((int)_dotNormalViews.count < count)
            {
                index++;
                
                UIImageView *normalView = [[UIImageView alloc] initWithImage:_normalDotImage];
                [_dotNormalViews addObject:normalView];
                [self addSubview:normalView];
                
                UIImageView *highlightedView = [[UIImageView alloc] initWithImage:[self dotImageWithColor:_dotColors[index % _dotColors.count] shadowWidth:_shadowWidth]];
                [_dotHighlightedViews addObject:highlightedView];
                [self addSubview:highlightedView];
            }
        }
        
        if (resetPage)
            [self setPage:0];
        
        [self setNeedsLayout];
    }
}

- (void)setPage:(CGFloat)page
{
    if (page < 0)
        page = 0;
    else if (page > _dotNormalViews.count - 1)
        page = _dotNormalViews.count - 1;
    
    for (int index = 0; index < (int)_dotNormalViews.count; index++)
    {
        CGFloat alpha = 0.0f;
        if (ABS(index - page) > 1)
            alpha = 0.0f;
        else
        {
            alpha = 1.0f - (ABS((CGFloat)index - page));
            alpha *= alpha * alpha;
        }
        
        if (alpha < 0.0f)
            alpha = 0.0f;
        if (alpha > 1)
            alpha = 1;
        
        ((UIView *)_dotHighlightedViews[index]).alpha = alpha;
    }
}

- (void)sizeToFit
{
    CGSize dotSize = CGSizeMake(_dotSize, _dotSize);
    CGFloat dotSpacing = _dotSpacing;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, dotSize.width * _dotNormalViews.count + dotSpacing * (_dotNormalViews.count - 1), dotSize.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize dotSize = CGSizeMake(_dotSize, _dotSize);
    
    CGFloat dotSpacing = _dotSpacing;
    CGFloat startX = (int)((self.bounds.size.width - (dotSize.width * _dotNormalViews.count + dotSpacing * (_dotNormalViews.count - 1))) / 2);

    for (int index = 0; index < (int)_dotNormalViews.count; index++)
    {
        ((UIView *)_dotNormalViews[index]).frame = CGRectMake(startX + index * (dotSize.width + dotSpacing), 0.0f, dotSize.width, dotSize.height);
        ((UIView *)_dotHighlightedViews[index]).frame = ((UIView *)_dotNormalViews[index]).frame;
    }
}

@end
