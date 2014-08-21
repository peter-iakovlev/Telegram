#import "TGModernGalleryImageItemImageView.h"

@interface TGModernGalleryImageItemImageView ()

@end

@implementation TGModernGalleryImageItemImageView

- (void)performProgressUpdate:(float)progress
{
    [super performProgressUpdate:progress];
    
    if (_progressChanged)
        _progressChanged(progress);
}

@end
