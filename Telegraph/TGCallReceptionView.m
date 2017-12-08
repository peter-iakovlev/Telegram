#import "TGCallReceptionView.h"

#import <LegacyComponents/TGImageUtils.h>

const NSInteger TGCallQualityViewBarCount = 4;
const CGSize TGCallQualityViewSize = { 24.0f, 10.0f };

const CGFloat TGCallQualityBarWidth = 3.0f;
const CGFloat TGCallQualityBarSpacing = 1.5f;

@interface TGCallReceptionView ()
{
    NSInteger _currentReception;
}
@end

@implementation TGCallReceptionView

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeRedraw;
        self.opaque = false;
        self.userInteractionEnabled = false;
        
        _currentReception = 4;
    }
    return self;
}

- (void)setSignalBars:(NSInteger)signalBars
{
    NSInteger newReception = signalBars;
    if (_currentReception != newReception)
    {
        _currentReception = newReception;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)__unused rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGFloat spacing = TGCallQualityBarSpacing;
    if (TGScreenScaling() > 2)
        spacing = 4.0f / 3.0f;
    
    for (NSInteger i = 0; i < TGCallQualityViewBarCount; i++) {
        CGFloat height = 4 + 2 * i;
        CGRect barRect = CGRectMake(rect.origin.x + i * (TGCallQualityBarWidth + spacing), TGCallQualityViewSize.height - height, TGCallQualityBarWidth, height);
        
        if (i >= _currentReception)
            CGContextSetAlpha(context, 0.4f);
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:barRect cornerRadius:1.0f];
        [path fill];
    }
}

@end
