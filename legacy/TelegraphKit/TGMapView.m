#import "TGMapView.h"

@implementation TGMapView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (iosMajorVersion() < 6)
    {
        for (UIView *subview in self.subviews)
        {
            if ([subview isKindOfClass:[UIImageView class]])
            {
                subview.autoresizingMask = 0;
                CGRect frame = subview.frame;
                frame.origin.y = 5;
                frame.origin.x = 5;
                subview.frame = frame;
                
                break;
            }
        }
    }
}

@end
