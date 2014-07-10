#import "TGVideoPreviewView.h"

@implementation TGVideoPreviewView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _videoLayer.frame = self.bounds;
}

@end
