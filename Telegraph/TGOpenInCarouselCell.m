#import "TGOpenInCarouselCell.h"

#import "TGFont.h"

#import "TGImageView.h"

#import "TGOpenInAppItem.h"
#import "TGOpenInSignals.h"

NSString *const TGOpenInCarouselCellIdentifier = @"TGOpenInCarouselCell";
const CGFloat TGOpenInCarouselCellIconCornerRadius = 16.0f;

@interface TGOpenInCarouselCell ()
{
    TGImageView *_imageView;
    UIImageView *_cornersView;
    UILabel *_titleLabel;
}
@end

@implementation TGOpenInCarouselCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        _imageView = [[TGImageView alloc] initWithFrame:CGRectMake(10.0f, 14.0f, 60.0f, 60.0f)];
        [self addSubview:_imageView];
        
        static dispatch_once_t onceToken;
        static UIImage *cornersImage;
        dispatch_once(&onceToken, ^
        {
            CGRect rect = CGRectMake(0, 0, TGOpenInCarouselCellIconCornerRadius * 2 + 1.0f, TGOpenInCarouselCellIconCornerRadius * 2 + 1.0f);
            
            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextSaveGState(context);
            
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillRect(context, rect);
            
            CGContextSetBlendMode(context, kCGBlendModeClear);
            
            CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
            CGContextFillEllipseInRect(context, rect);

            CGContextRestoreGState(context);
            
            CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
            CGContextSetLineWidth(context, 0.5f);
            CGContextStrokeEllipseInRect(context, CGRectInset(rect, 0.5f, 0.5f));
            
            cornersImage = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(TGOpenInCarouselCellIconCornerRadius, TGOpenInCarouselCellIconCornerRadius, TGOpenInCarouselCellIconCornerRadius, TGOpenInCarouselCellIconCornerRadius)];
            
            UIGraphicsEndImageContext();
        });
        
        _cornersView = [[UIImageView alloc] initWithImage:cornersImage];
        _cornersView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _cornersView.frame = _imageView.frame;
        [self addSubview:_cornersView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_imageView.frame) + 6.0f, frame.size.width, 16.0f)];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.font = TGSystemFontOfSize(11.0f);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor blackColor];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [_imageView reset];
}

- (void)setAppItem:(TGOpenInAppItem *)appItem
{
    _titleLabel.text = appItem.title;

    SSignal *iconSignal = nil;
    if (appItem.appIcon != nil)
        iconSignal = [SSignal single:appItem.appIcon];
    else
        iconSignal = [TGOpenInSignals iconForAppItem:appItem];
    
    [_imageView setSignal:iconSignal];
}

- (void)layoutSubviews
{
    
}

@end
