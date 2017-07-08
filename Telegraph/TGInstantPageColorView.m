#import "TGInstantPageColorView.h"

#import "TGImageUtils.h"

const CGFloat TGInstantPageColorRadius = 23.0f;
const CGFloat TGInstantPageColorSelectedRadius = 22.0f;
const CGFloat TGInstantPageColorSelectionRadius = 23.0f;
const CGFloat TGInstantPageColorSelectionThickness = 2.0f;
const CGFloat TGInstantPageColorSwatchSize = 46.0f;

@implementation TGInstantPageColorView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self setNeedsDisplay];
}

- (void)setIsOnDarkBackground:(bool)isOnDarkBackground {
    _isOnDarkBackground = isOnDarkBackground;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    bool isWhiteColor = [self.color isEqual:[UIColor whiteColor]];
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    
    if (self.isSelected) {
        CGContextFillEllipseInRect(context, CGRectMake(rect.size.width / 2 - TGInstantPageColorSelectedRadius, rect.size.height / 2 - TGInstantPageColorSelectedRadius, TGInstantPageColorSelectedRadius * 2, TGInstantPageColorSelectedRadius * 2));
        
        CGContextSetStrokeColorWithColor(context, TGAccentColor().CGColor);
        CGContextSetLineWidth(context, TGInstantPageColorSelectionThickness);
        
        CGContextStrokeEllipseInRect(context, CGRectMake(rect.size.width / 2 - TGInstantPageColorSelectionRadius + TGInstantPageColorSelectionThickness / 2, rect.size.height / 2 - TGInstantPageColorSelectionRadius + TGInstantPageColorSelectionThickness / 2, TGInstantPageColorSelectionRadius * 2 - TGInstantPageColorSelectionThickness, TGInstantPageColorSelectionRadius * 2 - TGInstantPageColorSelectionThickness));
    }
    else {
        CGContextFillEllipseInRect(context, CGRectMake(rect.size.width / 2 - TGInstantPageColorRadius, rect.size.height / 2 - TGInstantPageColorRadius, TGInstantPageColorRadius * 2, TGInstantPageColorRadius * 2));
        
        if (isWhiteColor && !self.isOnDarkBackground) {
            CGContextSetStrokeColorWithColor(context, UIColorRGB(0xb7b7b7).CGColor);
            CGContextSetLineWidth(context, TGScreenPixel);
            
            CGContextStrokeEllipseInRect(context, CGRectMake(rect.size.width / 2 - TGInstantPageColorRadius + TGInstantPageColorSelectionThickness / 2, rect.size.height / 2 - TGInstantPageColorRadius + TGInstantPageColorSelectionThickness / 2, TGInstantPageColorRadius * 2 - TGInstantPageColorSelectionThickness, TGInstantPageColorRadius * 2 - TGInstantPageColorSelectionThickness));
        }
    }
}

@end
