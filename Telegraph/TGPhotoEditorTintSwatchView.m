#import "TGPhotoEditorTintSwatchView.h"

const CGFloat TGPhotoEditorTintSwatchRadius = 8.5f;
const CGFloat TGPhotoEditorTintSwatchSelectedRadius = 6.5f;
const CGFloat TGPhotoEditorTintSwatchSelectionRadius = 10.5f;
const CGFloat TGPhotoEditorTintSwatchSelectionThickness = 2.0f;

@implementation TGPhotoEditorTintSwatchView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    bool isClearColor = [self.color isEqual:[UIColor clearColor]];
    UIColor *color = isClearColor ? [UIColor whiteColor] : self.color;
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, TGPhotoEditorTintSwatchSelectionThickness);
    
    if (self.isSelected)
    {
        CGContextFillEllipseInRect(context, CGRectMake(rect.size.width / 2 - TGPhotoEditorTintSwatchSelectedRadius, rect.size.height / 2 - TGPhotoEditorTintSwatchSelectedRadius, TGPhotoEditorTintSwatchSelectedRadius * 2, TGPhotoEditorTintSwatchSelectedRadius * 2));
        
        CGContextStrokeEllipseInRect(context, CGRectMake(rect.size.width / 2 - TGPhotoEditorTintSwatchSelectionRadius + TGPhotoEditorTintSwatchSelectionThickness / 2, rect.size.height / 2 - TGPhotoEditorTintSwatchSelectionRadius + TGPhotoEditorTintSwatchSelectionThickness / 2, TGPhotoEditorTintSwatchSelectionRadius * 2 - TGPhotoEditorTintSwatchSelectionThickness, TGPhotoEditorTintSwatchSelectionRadius * 2 - TGPhotoEditorTintSwatchSelectionThickness));
    }
    else
    {
        if (isClearColor)
        {
            CGContextStrokeEllipseInRect(context, CGRectMake(rect.size.width / 2 - TGPhotoEditorTintSwatchRadius + TGPhotoEditorTintSwatchSelectionThickness / 2, rect.size.height / 2 - TGPhotoEditorTintSwatchRadius + TGPhotoEditorTintSwatchSelectionThickness / 2, TGPhotoEditorTintSwatchRadius * 2 - TGPhotoEditorTintSwatchSelectionThickness, TGPhotoEditorTintSwatchRadius * 2 - TGPhotoEditorTintSwatchSelectionThickness));
        }
        else
        {
            CGContextFillEllipseInRect(context, CGRectMake(rect.size.width / 2 - TGPhotoEditorTintSwatchRadius, rect.size.height / 2 - TGPhotoEditorTintSwatchRadius, TGPhotoEditorTintSwatchRadius * 2, TGPhotoEditorTintSwatchRadius * 2));
        }
    }
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    [self setNeedsDisplay];
}

- (void)setSelected:(bool)selected
{
    [super setSelected:selected];
    
    [self setNeedsDisplay];
}

@end
