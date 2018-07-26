#import "TGMusicPlayerModeButton.h"
#import <LegacyComponents/LegacyComponents.h>

@implementation TGMusicPlayerModeButton

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [super setImage:image forState:state];
    
    if (state == UIControlStateNormal)
    {
        UIImage *highlightedImage = TGTintedImage(image, self.accentColor);
        [super setImage:highlightedImage forState:UIControlStateSelected];
        [super setImage:highlightedImage forState:UIControlStateSelected | UIControlStateHighlighted];
    }
}

@end
