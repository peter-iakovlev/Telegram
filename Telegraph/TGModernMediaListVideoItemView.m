#import "TGModernMediaListVideoItemView.h"

#import "TGModernMediaListVideoItem.h"
#import "TGImageView.h"

#import "TGFont.h"

@interface TGModernMediaListVideoItemView ()
{
    UIImageView *_shadowView;
    UILabel *_durationLabel;
}

@end

@implementation TGModernMediaListVideoItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        static UIImage *shadowImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(24.0f, 20.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGColorRef colors[2] = {
                CGColorRetain(UIColorRGBA(0x000000, 0.0f).CGColor),
                CGColorRetain(UIColorRGBA(0x000000, 0.8f).CGColor)
            };
            
            CFArrayRef colorsArray = CFArrayCreate(kCFAllocatorDefault, (const void **)&colors, 2, NULL);
            CGFloat locations[3] = {0.0f, 1.0f};
            
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colorsArray, (CGFloat const *)&locations);
            
            CFRelease(colorsArray);
            CFRelease(colors[0]);
            CFRelease(colors[1]);
            
            CGColorSpaceRelease(colorSpace);
            
            CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0f, 0.0f), CGPointMake(0.0f, 20.0f), 0);
            
            CFRelease(gradient);
            
            UIImage *videoIcon = [UIImage imageNamed:@"ModernMediaItemVideoIcon.png"];
            [videoIcon drawAtPoint:CGPointMake(5.0f, 20.0f - 5.0f - videoIcon.size.height)];
            
            shadowImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:23.0f topCapHeight:0.0f];
            UIGraphicsEndImageContext();
        });
        
        _shadowView = [[UIImageView alloc] initWithImage:shadowImage];
        [self addSubview:_shadowView];
        
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.backgroundColor = [UIColor clearColor];
        _durationLabel.textAlignment = NSTextAlignmentRight;
        _durationLabel.font = TGSystemFontOfSize(12.0f);
        _durationLabel.text = @" ";
        [_durationLabel sizeToFit];
        [self addSubview:_durationLabel];
    }
    return self;
}

- (void)setItem:(TGModernMediaListVideoItem *)item
{
    [super setItem:item];
    
    [super setImageUri:item.imageUri];

    int duration = (int)item.duration;
    _durationLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", duration / 60, duration % 60];
    [self setNeedsLayout];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _shadowView.frame = (CGRect){{0.0f, self.bounds.size.height - _shadowView.frame.size.height}, {self.frame.size.width, _shadowView.frame.size.height}};
    _durationLabel.frame = (CGRect){{5.0f, _shadowView.frame.origin.y + CGFloor((_shadowView.frame.size.height - _durationLabel.frame.size.height) / 2.0f) - 2.0f}, {self.frame.size.width - 5.0f - 4.0f, _shadowView.frame.size.height}};
}

- (UIImage *)transitionImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.imageView.image drawInRect:self.bounds blendMode:kCGBlendModeCopy alpha:1.0f];
    [_shadowView.image drawInRect:_shadowView.frame blendMode:kCGBlendModeNormal alpha:1.0f];
    CGContextTranslateCTM(context, _durationLabel.frame.origin.x, _durationLabel.frame.origin.y);
    [_durationLabel.layer drawInContext:context];
    CGContextTranslateCTM(context, -_durationLabel.frame.origin.x, -_durationLabel.frame.origin.y);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
